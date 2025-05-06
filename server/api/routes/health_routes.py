from flask import Blueprint, jsonify, current_app
from sqlalchemy import text
from datetime import datetime
from models.db import db

# Create blueprint for health routes
health_bp = Blueprint('health', __name__, url_prefix='/health')

@health_bp.route('', methods=['GET'])
def get_health():
    """Backend health check endpoint."""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "message": "Backend API is operational"
    })

@health_bp.route('/database', methods=['GET'])
def get_database_health():
    """Database health check endpoint."""
    try:
        # Execute a simple query to verify database connection
        db.session.execute(text("SELECT 1"))
        status = "healthy"
        message = "Database connection is established"
    except Exception as e:
        status = "unhealthy"
        message = f"Database error: {str(e)}"
    
    return jsonify({
        "status": status,
        "timestamp": datetime.utcnow().isoformat(),
        "message": message
    })

@health_bp.route('/system', methods=['GET'])
def get_system_health():
    """Get health status of all system components."""
    # Check backend health (always healthy if this endpoint is reached)
    backend_health = {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "message": "Backend API is operational"
    }
    
    # Check database health
    try:
        db.session.execute(text("SELECT 1"))
        db_status = "healthy"
        db_message = "Database connection is established"
    except Exception as e:
        db_status = "unhealthy"
        db_message = f"Database error: {str(e)}"
    
    database_health = {
        "status": db_status,
        "timestamp": datetime.utcnow().isoformat(),
        "message": db_message
    }
    
    # Return combined health status
    return jsonify({
        "backend": backend_health,
        "database": database_health
    })