import pytest
from rest_framework.reverse import reverse
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import AccessToken
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
def get_access_token():
    user, created = User.objects.get_or_create(username='test_user')
    if created:
        user.set_password('test_password')
        user.save()
    access_token = AccessToken.for_user(user)
    return str(access_token)

def test_api_product_creation():
    client = APIClient()
    access_token = get_access_token()
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')

    response = client.post("/api/products/create/")

    assert response.status_code == 200
