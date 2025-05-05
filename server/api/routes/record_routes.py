from flask import Blueprint, request, jsonify
from models.db import db, Record

# Create blueprint for record routes
record_bp = Blueprint('records', __name__, url_prefix='/records')

@record_bp.route('', methods=['GET'])
def get_records():
    """Get all records."""
    try:
        records = Record.query.order_by(Record.created_at.desc()).all()
        return jsonify([record.to_dict() for record in records])
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@record_bp.route('', methods=['POST'])
def create_record():
    """Create a new record."""
    try:
        data = request.get_json()
        
        if not data or 'message' not in data:
            return jsonify({"success": False, "error": "Message is required"}), 400
        
        message = data['message'].strip()
        if not message:
            return jsonify({"success": False, "error": "Message cannot be empty"}), 400
        
        new_record = Record(message=message)
        db.session.add(new_record)
        db.session.commit()
        
        return jsonify(new_record.to_dict()), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 500

@record_bp.route('/<int:record_id>', methods=['GET'])
def get_record(record_id):
    """Get a specific record by ID."""
    try:
        record = Record.query.get(record_id)
        
        if not record:
            return jsonify({"success": False, "error": "Record not found"}), 404
        
        return jsonify(record.to_dict())
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@record_bp.route('/<int:record_id>', methods=['DELETE'])
def delete_record(record_id):
    """Delete a specific record by ID."""
    try:
        record = Record.query.get(record_id)
        
        if not record:
            return jsonify({"success": False, "error": "Record not found"}), 404
        
        db.session.delete(record)
        db.session.commit()
        
        return jsonify({"success": True, "message": f"Record {record_id} deleted successfully"})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 500