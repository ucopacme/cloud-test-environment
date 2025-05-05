import os
from flask import Flask, jsonify
from flask_cors import CORS
from api.routes import register_routes
from models.db import init_db
from config.settings import get_config

def create_app(config_name=None):
    """Create and configure the Flask application."""
    app = Flask(__name__)
    
    # Load configuration based on environment
    if not config_name:
        config_name = os.environ.get('FLASK_ENV', 'development')
    
    app_config = get_config(config_name)
    app.config.from_object(app_config)
    
    # Enable CORS
    CORS(app, resources={r"/api/*": {"origins": app.config.get('CORS_ORIGINS', '*')}})
    
    # Initialize database
    init_db(app)
    
    # Register API routes
    register_routes(app)
    
    # Error handlers
    @app.errorhandler(404)
    def not_found(e):
        return jsonify({"success": False, "error": "Resource not found"}), 404
    
    @app.errorhandler(500)
    def server_error(e):
        return jsonify({"success": False, "error": "Internal server error"}), 500
    
    @app.route('/api/health')
    def health_check():
        """Health check endpoint for the backend API."""
        return jsonify({
            "status": "healthy",
            "timestamp": app_config.get_current_time(),
            "message": "Backend API is operational"
        })
    
    return app

if __name__ == '__main__':
    app = create_app()
    app.run(
        host=os.environ.get('FLASK_HOST', '0.0.0.0'),
        port=int(os.environ.get('FLASK_PORT', 5000))
    )