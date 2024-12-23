-- Create routines table
CREATE TABLE routines (
    routineid SERIAL PRIMARY KEY,
    userid INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    code TEXT,
    metadata_info JSONB,
    requirements TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tsvector_column TSVECTOR GENERATED ALWAYS AS (
        to_tsvector('english', name || ' ' || description)
    ) STORED
);
CREATE INDEX idx_routines_tsvector ON routines USING GIN(tsvector_column);


-- Create agents table
CREATE TABLE agents (
    agentid SERIAL PRIMARY KEY,
    userid INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    prompt TEXT,
    metadata_info JSONB,
    routines INT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tsvector_column TSVECTOR GENERATED ALWAYS AS (
        to_tsvector('english', name || ' ' || description)
    ) STORED
);
CREATE INDEX idx_agents_tsvector ON agents USING GIN(tsvector_column);

-- Create swarms table
CREATE TABLE swarms (
    swarmid SERIAL PRIMARY KEY,
    userid INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    metadata_info JSONB,
    graph JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tsvector_column TSVECTOR GENERATED ALWAYS AS (
        to_tsvector('english', name || ' ' || description)
    ) STORED
);
CREATE INDEX idx_swarms_tsvector ON swarms USING GIN(tsvector_column);

-- Create the users table with organization_id as a regular column
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    organization_id INT  -- organization_id without a foreign key constraint
);


CREATE TABLE settings (
    setting_id SERIAL PRIMARY KEY,  -- Primary key for unique identification
    user_id INT NOT NULL,           -- User ID to associate settings with a user
    settings JSONB,                 -- JSONB column to store user settings
    description TEXT,               -- Optional description of the settings
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Timestamp when the setting was created
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP   -- Timestamp when the setting was last updated
);

-- Create the organizations table
CREATE TABLE organizations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Insert the default organization
INSERT INTO organizations (name) VALUES ('default');


INSERT INTO routines (userid, name, description, code, metadata_info, requirements) VALUES
(1, 'applyDiscount', 'Apply a discount to the user''s cart.', 
$$
def applyDiscount():
    """Apply a discount to the user's cart."""
    print("[mock] Applying discount...")
    return "Applied discount of 11%"
$$, 
'{"category": "ecommerce", "complexity": "simple"}', 
$$
requests
numpy
$$),

(1, 'processRefund', 'Refund an item, ensuring user confirmation before processing.', 
$$
def processRefund(item_id, reason="NOT SPECIFIED"):
    """Refund an item with item_id of the form item_..."""
    print(f"[mock] Refunding item {item_id} because {reason}...")
    return "Success!"
$$, 
'{"category": "ecommerce", "complexity": "simple"}', 
$$
pandas
$$);




INSERT INTO agents (userid, name, description, prompt, metadata_info, routines) VALUES
(1, 'TriageAgent', 'Determine which agent is best suited to handle the user''s request, and transfer the conversation to that agent.', 'You are a customer care triage expert.' , 
 '{"agent_type": "text-processing", "active": false}', '{}'),
(1, 'SalesAgent', 'Be super enthusiastic about selling bees.', 'You are a sales expert' ,
 '{"agent_type": "chat", "active": true}', '{}'),
(1, 'RefundsAgent', 'Help the user with a refund. If the reason is that it was too expensive, offer the user a refund code. If they insist, then process the refund.', 
 'You are a refund specialist','{"agent_type": "automation", "active": true}', '{1,2}');

-- Insert an admin user linked to the default organization
INSERT INTO users (username, hashed_password, role, organization_id)
VALUES ('admin', '$2b$12$z/L8tFyoSZB14NVF.a5Leuginz7zB10poMaGZdl3TRBuhgT7t2moa', 'admin', 
        (SELECT id FROM organizations WHERE name = 'default'));

INSERT INTO settings (user_id, settings, description, created_at, updated_at)
VALUES 
(1, 
 '{"OPENAI_API_KEY": "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"}', 
 'API key for OpenAI integration', 
 CURRENT_TIMESTAMP, 
 CURRENT_TIMESTAMP);

-- Add this table creation script to the existing init.sql file

CREATE TABLE IF NOT EXISTS http_tracking (
    id SERIAL PRIMARY KEY,
    application_id VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    request JSONB NOT NULL,
    response JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tracking_application_id ON http_tracking(application_id);
CREATE INDEX idx_tracking_timestamp ON http_tracking(timestamp);
