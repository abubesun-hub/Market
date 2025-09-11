"""
Add branches and warehouses tables

Revision ID: 20250909_0002
Revises: 20250909_0001
Create Date: 2025-09-09
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '20250909_0002'
down_revision = '20250909_0001'
branch_labels = None
depends_on = None

def upgrade() -> None:
    op.create_table(
        'branches',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('code', sa.String(length=20), nullable=False, unique=True),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('address', sa.String(length=255), nullable=True),
    )

    op.create_table(
        'warehouses',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('code', sa.String(length=20), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('branch_id', sa.Integer, sa.ForeignKey('branches.id', ondelete='CASCADE'), nullable=False),
        sa.UniqueConstraint('code', 'branch_id', name='uq_warehouse_code_branch'),
    )

    # Optional: seed one branch + a main warehouse
    op.execute("INSERT INTO branches (code, name, address) VALUES ('BR1', 'Main Branch', 'N/A')")
    op.execute("INSERT INTO warehouses (code, name, branch_id) VALUES ('WH1', 'Main Warehouse', 1)")


def downgrade() -> None:
    op.drop_table('warehouses')
    op.drop_table('branches')