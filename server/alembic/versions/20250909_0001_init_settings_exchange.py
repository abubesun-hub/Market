"""
Initial settings and currency_rates tables

Revision ID: 20250909_0001
Revises: 
Create Date: 2025-09-09
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '20250909_0001'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    op.create_table(
        'app_settings',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('app_name', sa.String(length=100), nullable=False, server_default='Market API'),
        sa.Column('base_currency', sa.String(length=3), nullable=False, server_default='IQD'),
        sa.Column('iqd_step', sa.Integer, nullable=False, server_default='250'),
    )

    op.create_table(
        'currency_rates',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('from_currency', sa.String(length=3), nullable=False),
        sa.Column('to_currency', sa.String(length=3), nullable=False),
        sa.Column('effective_date', sa.Date, nullable=False),
        sa.Column('rate', sa.Numeric(18, 6), nullable=False),
        sa.UniqueConstraint('from_currency', 'to_currency', 'effective_date', name='uq_currency_rate_date')
    )

    # insert default settings row
    op.execute("INSERT INTO app_settings (app_name, base_currency, iqd_step) VALUES ('Market API', 'IQD', 250)")


def downgrade() -> None:
    op.drop_table('currency_rates')
    op.drop_table('app_settings')