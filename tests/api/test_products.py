import pytest
from rest_framework.test import APIClient
from rest_framework.authtoken.models import Token
from django.contrib.auth.models import User
from base.models import Product

def create_product():
    return Product.objects.create(
        name="Product Name",
        price=0,
        brand="Sample brand",
        countInStock=0,
        category="Sample category",
        description="Sample description"
    )

@pytest.mark.django_db
def test_product_creation():
    p = create_product()
    assert isinstance(p, Product) is True
    assert p.name == "Product Name"

@pytest.mark.django_db
def test_api_product_creation():
    # Create a user and obtain a token
    user = User.objects.create_user(username='testuser', password='testpassword')
    token = Token.objects.create(user=user)

    client = APIClient()
    client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)

    response = client.post("/api/products/create/")

    assert response.status_code == 200
