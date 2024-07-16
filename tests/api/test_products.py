import pytest

# @pytest.mark.django_db
# def test_product_created():
#   Product.objects.create
from rest_framework.reverse import reverse
from rest_framework.test import APIClient
from django.contrib.auth.models import User
from base.models import Product
from rest_framework_simplejwt.tokens import AccessToken  # Adjust based on your JWT library


def create_product():
  return Product.objects.create(
        name=" Product Name ",
        price=0,
        brand="Sample brand ",
        countInStock=0,
        category="Sample category",
        description=" ")

@pytest.mark.django_db

def get_access_token():
    # Implement a function to retrieve a valid JWT access token
    # This could involve logging in or fetching from a mock token generator
    # Example:
    user = User.objects.get(username='test_user')
    access_token = AccessToken.for_user(user)
    return str(access_token)

def test_api_product_creation():
    client = APIClient()
    access_token = get_access_token()
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')

    response = client.post("/api/products/create/")

    assert response.status_code == 200
