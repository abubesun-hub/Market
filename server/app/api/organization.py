from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..core.db import get_db
from ..repositories.organization_repo import OrganizationRepository
from ..schemas.organization import BranchCreate, BranchOut, WarehouseCreate, WarehouseOut

router = APIRouter()

# Branches
@router.get("/branches", response_model=list[BranchOut])
def list_branches(db: Session = Depends(get_db)):
    repo = OrganizationRepository(db)
    return repo.list_branches()

@router.post("/branches", response_model=BranchOut)
def create_branch(payload: BranchCreate, db: Session = Depends(get_db)):
    repo = OrganizationRepository(db)
    try:
        return repo.create_branch(code=payload.code, name=payload.name, address=payload.address)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Warehouses
@router.get("/warehouses", response_model=list[WarehouseOut])
def list_warehouses(branch_id: int | None = None, db: Session = Depends(get_db)):
    repo = OrganizationRepository(db)
    return repo.list_warehouses(branch_id=branch_id)

@router.post("/warehouses", response_model=WarehouseOut)
def create_warehouse(payload: WarehouseCreate, db: Session = Depends(get_db)):
    repo = OrganizationRepository(db)
    try:
        return repo.create_warehouse(code=payload.code, name=payload.name, branch_id=payload.branch_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))