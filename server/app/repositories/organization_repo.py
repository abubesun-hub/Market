from sqlalchemy.orm import Session
from sqlalchemy import select
from ..models.organization import Branch, Warehouse

class OrganizationRepository:
    def __init__(self, db: Session):
        self.db = db

    # Branches
    def list_branches(self) -> list[Branch]:
        return self.db.execute(select(Branch).order_by(Branch.id)).scalars().all()

    def create_branch(self, *, code: str, name: str, address: str | None) -> Branch:
        obj = Branch(code=code, name=name, address=address)
        self.db.add(obj)
        self.db.commit()
        self.db.refresh(obj)
        return obj

    # Warehouses
    def list_warehouses(self, *, branch_id: int | None = None) -> list[Warehouse]:
        stmt = select(Warehouse)
        if branch_id:
            stmt = stmt.where(Warehouse.branch_id == branch_id)
        return self.db.execute(stmt.order_by(Warehouse.id)).scalars().all()

    def create_warehouse(self, *, code: str, name: str, branch_id: int) -> Warehouse:
        obj = Warehouse(code=code, name=name, branch_id=branch_id)
        self.db.add(obj)
        self.db.commit()
        self.db.refresh(obj)
        return obj