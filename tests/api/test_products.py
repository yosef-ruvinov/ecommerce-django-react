import pytest
from rest_framework.reverse import reverse
from rest_framework.test import APIClient
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

# API test - Integration testing
@pytest.mark.django_db
def test_api_product_creation():
    client = APIClient()

    # Create a test user
    test_user = User.objects.create_user(username='testuser', password='testpassword')

    # Authenticate the client
    response = client.post('/api/token/', {'username': 'testuser', 'password': 'testpassword'})
    token = response.data['access']
    client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)

    # Create a product using the authenticated client
    response = client.post("/api/products/create/", {
        'name': 'New Product',
        'price': 10,
        'brand': 'New Brand',
        'countInStock': 5,
        'category': 'New Category',
        'description': 'New Description'
    })

    assert response.status_code == 200
