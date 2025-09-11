from pydantic import BaseModel

class BranchCreate(BaseModel):
    code: str
    name: str
    address: str | None = None

class BranchOut(BaseModel):
    id: int
    code: str
    name: str
    address: str | None = None

    class Config:
        from_attributes = True

class WarehouseCreate(BaseModel):
    code: str
    name: str
    branch_id: int

class WarehouseOut(BaseModel):
    id: int
    code: str
    name: str
    branch_id: int

    class Config:
        from_attributes = True