import pytest
from rest_framework.test import APIClient
from base.models import Product
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token

def create_product():
    return Product.objects.create(
        name="Product Name",
        price=0,
        brand="Sample brand",
        countInStock=0,
        category="Sample category",
        description="")

@pytest.mark.django_db
def test_product_creation():
    p = create_product()
    assert isinstance(p, Product) is True
    assert p.name == "Product Name"

@pytest.mark.django_db
def test_api_product_creation():
    # Create a user and a token
    user = User.objects.create_user(username='testuser', password='testpassword')
    token, created = Token.objects.get_or_create(user=user)

    client = APIClient()
    client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)

    # Add data to the post request if required
    data = {
        "name": "New Product",
        "price": 100,
        "brand": "New Brand",
        "countInStock": 10,
        "category": "New Category",
        "description": "New Description"
    }

    response = client.post("/api/products/create/", data, format='json')

    assert response.status_code == 201  # Assuming 201 Created is the expected status code

    # Optionally, check if the product was created
    response_data = response.data
    assert response_data['name'] == "New Product"
