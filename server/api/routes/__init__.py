from flask import Blueprint
from .record_routes import record_bp
from .health_routes import health_bp

def register_routes(app):
    """Register all API routes with the Flask application."""
    # Create a parent Blueprint for all API routes
    api_bp = Blueprint('api', __name__, url_prefix='/api')
    
    # Register individual route blueprints with the API blueprint
    api_bp.register_blueprint(record_bp)
    api_bp.register_blueprint(health_bp)
    
    # Register the main API blueprint with the app
    app.register_blueprint(api_bp)