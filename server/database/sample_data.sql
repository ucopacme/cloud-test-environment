-- Cloud Test Environment Sample Data
-- This script populates the database with sample data for development and testing

-- Use the database
USE cloud_test_db;

-- --------------------
-- Records Data
-- --------------------

-- Clear existing records data
TRUNCATE TABLE records;

-- Insert sample records
INSERT INTO records (message, created_at, updated_at) VALUES
('Hello world! This is the first test message.', NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 5 DAY),
('Testing database connectivity from the backend API.', NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 4 DAY),
('The cloud test environment is up and running!', NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 3 DAY),
('This message tests the database write functionality.', NOW() - INTERVAL 2 DAY, NOW() - INTERVAL 2 DAY),
('Integration between frontend and backend is working properly.', NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 1 DAY),
('The load balancer is distributing traffic correctly.', NOW() - INTERVAL 12 HOUR, NOW() - INTERVAL 12 HOUR),
('Database backup and recovery mechanisms verified.', NOW() - INTERVAL 6 HOUR, NOW() - INTERVAL 6 HOUR),
('Testing system monitoring and health check endpoints.', NOW() - INTERVAL 3 HOUR, NOW() - INTERVAL 3 HOUR),
('All API endpoints are responding as expected.', NOW() - INTERVAL 1 HOUR, NOW() - INTERVAL 1 HOUR),
('Most recent test message in the system.', NOW(), NOW());

-- --------------------
-- System Events Data
-- --------------------

-- Clear existing system events data
TRUNCATE TABLE system_events;

-- Insert sample system events
INSERT INTO system_events (event_type, component, message, occurred_at, resolved, resolved_at) VALUES
('INFO', 'backend', 'Backend service started successfully', NOW() - INTERVAL 7 DAY, TRUE, NOW() - INTERVAL 7 DAY),
('WARNING', 'database', 'High database connection count detected', NOW() - INTERVAL 6 DAY, TRUE, NOW() - INTERVAL 6 DAY + INTERVAL 30 MINUTE),
('ERROR', 'frontend', 'Failed to load frontend assets', NOW() - INTERVAL 5 DAY, TRUE, NOW() - INTERVAL 5 DAY + INTERVAL 15 MINUTE),
('CRITICAL', 'database', 'Database connection failure', NOW() - INTERVAL 4 DAY, TRUE, NOW() - INTERVAL 4 DAY + INTERVAL 45 MINUTE),
('INFO', 'backend', 'Backend API response time improved after optimization', NOW() - INTERVAL 3 DAY, TRUE, NOW() - INTERVAL 3 DAY),
('WARNING', 'frontend', 'Slow response time from backend API', NOW() - INTERVAL 2 DAY, TRUE, NOW() - INTERVAL 2 DAY + INTERVAL 20 MINUTE),
('ERROR', 'backend', 'Failed to write to database', NOW() - INTERVAL 1 DAY, TRUE, NOW() - INTERVAL 1 DAY + INTERVAL 10 MINUTE),
('INFO', 'frontend', 'Frontend application updated to version 1.2.0', NOW() - INTERVAL 12 HOUR, TRUE, NOW() - INTERVAL 12 HOUR),
('WARNING', 'database', 'Database approaching storage capacity limit', NOW() - INTERVAL 6 HOUR, FALSE, NULL),
('CRITICAL', 'backend', 'Backend service unresponsive', NOW() - INTERVAL 1 HOUR, FALSE, NULL);

-- --------------------
-- Health Checks Data
-- --------------------

-- Clear existing health checks data
TRUNCATE TABLE health_checks;

-- Insert sample health checks
INSERT INTO health_checks (component, status, message, checked_at) VALUES
('frontend', 'healthy', 'Frontend is operational', NOW() - INTERVAL 1 DAY),
('backend', 'healthy', 'Backend API is operational', NOW() - INTERVAL 1 DAY),
('database', 'healthy', 'Database connection is established', NOW() - INTERVAL 1 DAY),
('frontend', 'healthy', 'Frontend is operational', NOW() - INTERVAL 12 HOUR),
('backend', 'unhealthy', 'Backend API timeout', NOW() - INTERVAL 12 HOUR),
('database', 'healthy', 'Database connection is established', NOW() - INTERVAL 12 HOUR),
('frontend', 'healthy', 'Frontend is operational', NOW() - INTERVAL 6 HOUR),
('backend', 'healthy', 'Backend API is operational', NOW() - INTERVAL 6 HOUR),
('database', 'healthy', 'Database connection is established', NOW() - INTERVAL 6 HOUR),
('frontend', 'healthy', 'Frontend is operational', NOW() - INTERVAL 1 HOUR),
('backend', 'healthy', 'Backend API is operational', NOW() - INTERVAL 1 HOUR),
('database', 'unhealthy', 'Database error: Connection refused', NOW() - INTERVAL 1 HOUR),
('frontend', 'healthy', 'Frontend is operational', NOW()),
('backend', 'healthy', 'Backend API is operational', NOW()),
('database', 'healthy', 'Database connection is established', NOW());

-- --------------------
-- Configuration Data
-- --------------------

-- Clear existing configuration data
TRUNCATE TABLE configurations;

-- Insert sample configuration settings
INSERT INTO configurations (config_key, config_value, description, active) VALUES
('app.name', 'Cloud Test Environment', 'Application name', TRUE),
('app.version', '1.0.0', 'Application version', TRUE),
('ui.theme', 'light', 'UI theme (light/dark)', TRUE),
('ui.refresh_interval', '30', 'UI refresh interval in seconds', TRUE),
('api.timeout', '5000', 'API timeout in milliseconds', TRUE),
('api.retry_count', '3', 'Number of API retry attempts', TRUE),
('db.connection_pool_size', '10', 'Database connection pool size', TRUE),
('feature.health_monitoring', 'true', 'Enable health monitoring feature', TRUE),
('feature.system_events', 'true', 'Enable system events feature', TRUE),
('logging.level', 'INFO', 'Application logging level', TRUE);

-- --------------------
-- Optional: Advanced Feature Sample Data
-- --------------------

-- Clear existing users data
TRUNCATE TABLE users;

-- Insert sample users (password hash for 'password123')
INSERT INTO users (username, email, password_hash, created_at, is_active) VALUES
('admin', 'admin@example.com', '$2a$12$RP4GZf5Cx0xP9JxA3qmAL.2mZjYM28zpC4NIV8dOUjx3F.XGtHtOW', NOW() - INTERVAL 30 DAY, TRUE),
('johndoe', 'john.doe@example.com', '$2a$12$RP4GZf5Cx0xP9JxA3qmAL.2mZjYM28zpC4NIV8dOUjx3F.XGtHtOW', NOW() - INTERVAL 25 DAY, TRUE),
('janedoe', 'jane.doe@example.com', '$2a$12$RP4GZf5Cx0xP9JxA3qmAL.2mZjYM28zpC4NIV8dOUjx3F.XGtHtOW', NOW() - INTERVAL 20 DAY, TRUE),
('testuser', 'test@example.com', '$2a$12$RP4GZf5Cx0xP9JxA3qmAL.2mZjYM28zpC4NIV8dOUjx3F.XGtHtOW', NOW() - INTERVAL 15 DAY, FALSE);

-- Clear existing API metrics data
TRUNCATE TABLE api_metrics;

-- Insert sample API metrics
INSERT INTO api_metrics (endpoint, method, status_code, response_time_ms, request_timestamp, client_ip) VALUES
('/api/health', 'GET', 200, 12, NOW() - INTERVAL 1 DAY, '192.168.1.10'),
('/api/health/database', 'GET', 200, 45, NOW() - INTERVAL 1 DAY, '192.168.1.10'),
('/api/health/system', 'GET', 200, 67, NOW() - INTERVAL 1 DAY, '192.168.1.10'),
('/api/records', 'GET', 200, 78, NOW() - INTERVAL 1 DAY, '192.168.1.11'),
('/api/records', 'POST', 201, 120, NOW() - INTERVAL 1 DAY, '192.168.1.11'),
('/api/health', 'GET', 200, 10, NOW() - INTERVAL 12 HOUR, '192.168.1.12'),
('/api/health/database', 'GET', 200, 42, NOW() - INTERVAL 12 HOUR, '192.168.1.12'),
('/api/records', 'GET', 200, 65, NOW() - INTERVAL 12 HOUR, '192.168.1.12'),
('/api/records', 'POST', 400, 30, NOW() - INTERVAL 12 HOUR, '192.168.1.12'),
('/api/health', 'GET', 200, 11, NOW() - INTERVAL 6 HOUR, '192.168.1.13'),
('/api/health/database', 'GET', 500, 2010, NOW() - INTERVAL 6 HOUR, '192.168.1.13'),
('/api/health/system', 'GET', 500, 2050, NOW() - INTERVAL 6 HOUR, '192.168.1.13'),
('/api/records', 'GET', 500, 2100, NOW() - INTERVAL 6 HOUR, '192.168.1.13'),
('/api/health', 'GET', 200, 9, NOW() - INTERVAL 1 HOUR, '192.168.1.14'),
('/api/health/database', 'GET', 200, 40, NOW() - INTERVAL 1 HOUR, '192.168.1.14'),
('/api/health/system', 'GET', 200, 58, NOW() - INTERVAL 1 HOUR, '192.168.1.14'),
('/api/records', 'GET', 200, 62, NOW() - INTERVAL 1 HOUR, '192.168.1.14'),
('/api/records', 'POST', 201, 110, NOW() - INTERVAL 1 HOUR, '192.168.1.14');