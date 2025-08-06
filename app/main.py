from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime


# open api docs: http://127.0.0.1:8000/docs

description = """
TestApp API helps you do awesome stuff. 🚀

## Items

You can **read items**.

## Users

You will be able to:

* **Create users** (_not implemented_).
* **Read users** (_not implemented_).
"""

app = FastAPI(
    title="Test App",
    description=description,
    summary="Just test app.",
    version="0.0.1",
    terms_of_service="http://example.com/terms/",
    contact={
        "name": "No Contact",
        "url": "http://www.example.com/contact/",
        "email": "dp@example.com",
    },
    license_info={
        "name": "Apache 2.0",
        "url": "https://www.apache.org/licenses/LICENSE-2.0.html",
    },
)

# curl http://127.0.0.1:8000/healthz
@app.get("/healthz")
def healthz():
    return {"ok": True}

# curl http://127.0.0.1:8000/
@app.get("/")
def read_root():
    return {"hello": f"fastapi {datetime.now()}"}


# curl http://127.0.0.1:8000/items/?skip=0&limit=10
fake_items_db = [{"item_name": "Foo"}, {"item_name": "Bar"}, {"item_name": "Baz"}]
@app.get("/items/")
async def read_item(skip: int = 0, limit: int = 10):
    return fake_items_db[skip : skip + limit]

class Item(BaseModel):
    name: str
    description: str | None = None
    price: float
    tax: float | None = None

@app.post("/items2/")
async def create_item(item: Item):
    return item
