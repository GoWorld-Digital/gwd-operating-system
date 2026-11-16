-- /opt/gwd/init.sql
-- GoWorld.Digital (ATLASHUB DIGITAL LTD — UK #17379237)
-- GWD Operating System — PostgreSQL + pgvector Schema Bootstrap
-- Embedding model: Amazon Titan Embeddings v2 -> vector(1024)

-- ── Extensions ────────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ── Schemas ───────────────────────────────────────────────────────────────────
CREATE SCHEMA IF NOT EXISTS ops;
CREATE SCHEMA IF NOT EXISTS gbrain;
CREATE SCHEMA IF NOT EXISTS soul;
CREATE SCHEMA IF NOT EXISTS crm;

-- ─────────────────────────────────────────────────────────────────────────────
-- OPS: Authoritative Task & Mission State (PMO / GitHub Projects Sync)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ops.tasks (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id         TEXT NOT NULL DEFAULT 'gwd',
  task_key          TEXT NOT NULL UNIQUE,           -- Immutable external/mission key
  title             TEXT NOT NULL,
  description       TEXT,
  department        TEXT NOT NULL,                  -- executive_pmo | technology_foundry | radar_tech_media | academy_community | revenue_crm | memory_ops
  circuit           TEXT,                           -- intelligence_foundry | revenue_growth | memory_governance
  assigned_agent    TEXT,
  status            TEXT NOT NULL DEFAULT 'queued', -- queued | in_progress | review_requested | approved | blocked | done | cancelled
  priority          TEXT NOT NULL DEFAULT 'medium', -- critical | high | medium | low
  approval_required BOOLEAN NOT NULL DEFAULT FALSE,
  approved_by       TEXT,
  approved_at       TIMESTAMPTZ,
  github_issue_url  TEXT,
  token_budget      INTEGER DEFAULT 0,
  tokens_used       INTEGER DEFAULT 0,
  metadata          JSONB DEFAULT '{}',
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ops_tasks_tenant_idx     ON ops.tasks (tenant_id);
CREATE INDEX IF NOT EXISTS ops_tasks_status_idx     ON ops.tasks (status);
CREATE INDEX IF NOT EXISTS ops_tasks_department_idx ON ops.tasks (department);
CREATE INDEX IF NOT EXISTS ops_tasks_agent_idx      ON ops.tasks (assigned_agent);

-- ─────────────────────────────────────────────────────────────────────────────
-- GBRAIN: Knowledge Graph Nodes (GWD Knowledge Vault + Agent Artifacts)
-- Embedding dimension: 1024 (Amazon Titan Embeddings v2)
-- Memory tiers: 'executive' vs 'operational'
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS gbrain.knowledge_nodes (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id       TEXT NOT NULL DEFAULT 'gwd',
  node_key        TEXT NOT NULL UNIQUE,
  title           TEXT NOT NULL,
  content         TEXT NOT NULL,
  content_hash    TEXT NOT NULL,
  embedding       vector(1024),
  memory_tier     TEXT NOT NULL DEFAULT 'operational' CHECK (memory_tier IN ('executive', 'operational')),
  node_type       TEXT NOT NULL DEFAULT 'note',
  department      TEXT,
  tags            TEXT[] DEFAULT '{}',
  backlinks       TEXT[] DEFAULT '{}',
  metadata        JSONB DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  indexed_at      TIMESTAMPTZ,
  is_archived     BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS gbrain_nodes_embedding_idx
  ON gbrain.knowledge_nodes
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);

CREATE INDEX IF NOT EXISTS gbrain_nodes_tenant_idx     ON gbrain.knowledge_nodes (tenant_id);
CREATE INDEX IF NOT EXISTS gbrain_nodes_tier_idx       ON gbrain.knowledge_nodes (memory_tier);
CREATE INDEX IF NOT EXISTS gbrain_nodes_type_idx       ON gbrain.knowledge_nodes (node_type);
CREATE INDEX IF NOT EXISTS gbrain_nodes_department_idx ON gbrain.knowledge_nodes (department);
CREATE INDEX IF NOT EXISTS gbrain_nodes_tags_idx       ON gbrain.knowledge_nodes USING GIN (tags);
CREATE INDEX IF NOT EXISTS gbrain_nodes_title_trgm     ON gbrain.knowledge_nodes USING GIN (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS gbrain_nodes_updated_idx    ON gbrain.knowledge_nodes (updated_at DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- GBRAIN: Knowledge Graph Edges
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS gbrain.knowledge_edges (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  source_id       UUID NOT NULL REFERENCES gbrain.knowledge_nodes(id) ON DELETE CASCADE,
  target_id       UUID NOT NULL REFERENCES gbrain.knowledge_nodes(id) ON DELETE CASCADE,
  edge_type       TEXT NOT NULL DEFAULT 'links_to',
  weight          FLOAT DEFAULT 1.0,
  metadata        JSONB DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (source_id, target_id, edge_type)
);

CREATE INDEX IF NOT EXISTS gbrain_edges_source_idx ON gbrain.knowledge_edges (source_id);
CREATE INDEX IF NOT EXISTS gbrain_edges_target_idx ON gbrain.knowledge_edges (target_id);
CREATE INDEX IF NOT EXISTS gbrain_edges_type_idx   ON gbrain.knowledge_edges (edge_type);

-- ─────────────────────────────────────────────────────────────────────────────
-- SOUL: Agent Episodic Memory & State
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS soul.agent_states (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id       TEXT NOT NULL DEFAULT 'gwd',
  agent_id        TEXT NOT NULL,
  agent_role      TEXT NOT NULL,
  department      TEXT NOT NULL,
  soul_content    TEXT NOT NULL,
  soul_embedding  vector(1024),
  session_id      TEXT,
  status          TEXT NOT NULL DEFAULT 'idle',
  task_context    JSONB DEFAULT '{}',
  memory_summary  TEXT,
  iteration_count INTEGER NOT NULL DEFAULT 0,
  metadata        JSONB DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS soul_agent_states_agent_id_idx ON soul.agent_states (agent_id);
CREATE INDEX IF NOT EXISTS soul_agent_states_department_idx      ON soul.agent_states (department);
CREATE INDEX IF NOT EXISTS soul_agent_states_status_idx          ON soul.agent_states (status);
CREATE INDEX IF NOT EXISTS soul_agent_states_embedding_idx
  ON soul.agent_states
  USING ivfflat (soul_embedding vector_cosine_ops)
  WITH (lists = 50);

-- ─────────────────────────────────────────────────────────────────────────────
-- SOUL: Episodic Memory Log (partitioned)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS soul.memory_events (
  id              BIGSERIAL,
  tenant_id       TEXT NOT NULL DEFAULT 'gwd',
  agent_id        TEXT NOT NULL,
  memory_tier     TEXT NOT NULL DEFAULT 'operational' CHECK (memory_tier IN ('executive', 'operational')),
  event_type      TEXT NOT NULL,
  session_id      TEXT,
  content         TEXT,
  embedding       vector(1024),
  input_tokens    INTEGER DEFAULT 0,
  output_tokens   INTEGER DEFAULT 0,
  model_id        TEXT,
  duration_ms     INTEGER,
  metadata        JSONB DEFAULT '{}',
  occurred_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (id, occurred_at)
) PARTITION BY RANGE (occurred_at);

CREATE TABLE IF NOT EXISTS soul.memory_events_2026_11
  PARTITION OF soul.memory_events
  FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');

CREATE TABLE IF NOT EXISTS soul.memory_events_2026_12
  PARTITION OF soul.memory_events
  FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');

CREATE INDEX IF NOT EXISTS soul_memory_events_agent_idx   ON soul.memory_events (agent_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS soul_memory_events_session_idx ON soul.memory_events (session_id);
CREATE INDEX IF NOT EXISTS soul_memory_events_type_idx    ON soul.memory_events (event_type);
CREATE INDEX IF NOT EXISTS soul_memory_events_tier_idx    ON soul.memory_events (memory_tier);

-- ─────────────────────────────────────────────────────────────────────────────
-- CRM: AI-Native Lead & Account Management
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS crm.leads (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id         TEXT NOT NULL DEFAULT 'gwd',
  external_id       TEXT UNIQUE,
  first_name        TEXT,
  last_name         TEXT,
  email             TEXT,
  company           TEXT,
  title             TEXT,
  phone             TEXT,
  source            TEXT,
  status            TEXT NOT NULL DEFAULT 'new',
  score             INTEGER DEFAULT 0,
  assigned_agent    TEXT,
  notes             TEXT,
  notes_embedding   vector(1024),
  tags              TEXT[] DEFAULT '{}',
  metadata          JSONB DEFAULT '{}',
  last_contacted_at TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS crm_leads_tenant_idx      ON crm.leads (tenant_id);
CREATE INDEX IF NOT EXISTS crm_leads_status_idx      ON crm.leads (status);
CREATE INDEX IF NOT EXISTS crm_leads_score_idx       ON crm.leads (score DESC);
CREATE INDEX IF NOT EXISTS crm_leads_assigned_idx    ON crm.leads (assigned_agent);
CREATE INDEX IF NOT EXISTS crm_leads_source_idx      ON crm.leads (source);
CREATE INDEX IF NOT EXISTS crm_leads_email_idx       ON crm.leads (email);
CREATE INDEX IF NOT EXISTS crm_leads_tags_idx        ON crm.leads USING GIN (tags);
CREATE INDEX IF NOT EXISTS crm_leads_notes_embed_idx
  ON crm.leads
  USING ivfflat (notes_embedding vector_cosine_ops)
  WITH (lists = 50);

CREATE TABLE IF NOT EXISTS crm.interactions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id       TEXT NOT NULL DEFAULT 'gwd',
  lead_id         UUID NOT NULL REFERENCES crm.leads(id) ON DELETE CASCADE,
  channel         TEXT NOT NULL,
  direction       TEXT NOT NULL,
  agent_id        TEXT,
  content         TEXT,
  embedding       vector(1024),
  sentiment       TEXT,
  metadata        JSONB DEFAULT '{}',
  occurred_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS crm_interactions_lead_idx    ON crm.interactions (lead_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS crm_interactions_channel_idx ON crm.interactions (channel);
CREATE INDEX IF NOT EXISTS crm_interactions_agent_idx   ON crm.interactions (agent_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- Utility: updated_at auto-trigger
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ops_tasks_updated
  BEFORE UPDATE ON ops.tasks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_gbrain_nodes_updated
  BEFORE UPDATE ON gbrain.knowledge_nodes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_soul_agent_states_updated
  BEFORE UPDATE ON soul.agent_states
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_crm_leads_updated
  BEFORE UPDATE ON crm.leads
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ─────────────────────────────────────────────────────────────────────────────
-- Semantic search helper function (Amazon Titan v2 — 1024 dims)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION gbrain.search_nodes(
  query_embedding   vector(1024),
  match_count       INT DEFAULT 10,
  filter_tier       TEXT DEFAULT NULL,
  filter_department TEXT DEFAULT NULL,
  filter_type       TEXT DEFAULT NULL
)
RETURNS TABLE (
  id          UUID,
  node_key    TEXT,
  title       TEXT,
  content     TEXT,
  memory_tier TEXT,
  node_type   TEXT,
  department  TEXT,
  tags        TEXT[],
  similarity  FLOAT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    n.id,
    n.node_key,
    n.title,
    n.content,
    n.memory_tier,
    n.node_type,
    n.department,
    n.tags,
    1 - (n.embedding <=> query_embedding) AS similarity
  FROM gbrain.knowledge_nodes n
  WHERE
    n.tenant_id = 'gwd'
    AND n.is_archived = FALSE
    AND n.embedding IS NOT NULL
    AND (filter_tier IS NULL OR n.memory_tier = filter_tier)
    AND (filter_department IS NULL OR n.department = filter_department)
    AND (filter_type IS NULL OR n.node_type = filter_type)
  ORDER BY n.embedding <=> query_embedding
  LIMIT match_count;
END;
$$ LANGUAGE plpgsql;

-- Seed: core GWD agent states
INSERT INTO soul.agent_states (tenant_id, agent_id, agent_role, department, soul_content, status)
VALUES
  ('gwd', 'gwd-pmo',             'orchestrator',    'executive_pmo',      '# GWD Executive PMO\n\nCoordinates Daily Pulse, task routing, and human-in-the-loop approvals.', 'idle'),
  ('gwd', 'gwd-foundry-auditor', 'reality_auditor', 'technology_foundry', '# GWD Foundry Auditor\n\nValidates open-source candidates, licenses, security posture, and MVP builds.', 'idle'),
  ('gwd', 'gwd-memory-indexer',  'indexer',         'memory_ops',         '# GWD Memory Indexer\n\nIndexes GWD Knowledge Vault into GBrain using Amazon Titan Embeddings v2 (1024-dim).', 'idle')
ON CONFLICT (agent_id) DO NOTHING;
