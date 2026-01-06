from flask import request, jsonify
from your_app import app, db
from your_app.models import Product, Inventory
from sqlalchemy.exc import IntegrityError


@app.route('/api/products', methods=['POST'])
def create_new_product():
    payload = request.get_json()

    if not payload:
        return jsonify({"error": "Request body is missing"}), 400

    if 'name' not in payload or 'sku' not in payload:
        return jsonify({"error": "Product name and SKU are required"}), 400

    try:
        product = Product(
            name=payload['name'],
            sku=payload['sku'],
            price=payload.get('price')
        )

        db.session.add(product)
        db.session.flush()  # ensures product ID is generated

        if payload.get('warehouse_id') and payload.get('initial_quantity'):
            inventory = Inventory(
                product_id=product.id,
                warehouse_id=payload['warehouse_id'],
                quantity=payload['initial_quantity']
            )
            db.session.add(inventory)

        db.session.commit()

        return jsonify({
            "message": "Product successfully created",
            "product_id": product.id
        }), 201

    except IntegrityError:
        db.session.rollback()
        return jsonify({"error": "Duplicate SKU detected"}), 409

    except Exception:
        db.session.rollback()
        return jsonify({"error": "Product creation failed"}), 500
