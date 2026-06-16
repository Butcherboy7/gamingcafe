"""initial_schema

Revision ID: e6edd257a7ab
Revises: 
Create Date: 2026-06-16 09:22:45.745254

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import TSTZRANGE


# revision identifiers, used by Alembic.
revision: str = 'e6edd257a7ab'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Enable btree_gist extension (needed for exclusion constraint)
    op.execute("CREATE EXTENSION IF NOT EXISTS btree_gist;")

    # 2. Define Enum types (Alembic doesn't automatically drop/create enum types nicely in Postgres without help)
    staff_role_enum = sa.Enum('OWNER', 'MANAGER', 'STAFF', name='staff_role_enum')
    pc_status_enum = sa.Enum('ONLINE', 'MAINTENANCE', name='pc_status_enum')
    booking_status_enum = sa.Enum('PENDING', 'CONFIRMED', 'ACTIVE', 'COMPLETED', 'CANCELLED', name='booking_status_enum')
    payment_status_enum = sa.Enum('PENDING', 'PAID_ONLINE', 'PAID_CASH', name='payment_status_enum')

    # 3. Create tables
    op.create_table(
        'users',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('email', sa.String(), nullable=False),
        sa.Column('auth_provider', sa.String(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_users_email'), 'users', ['email'], unique=True)

    op.create_table(
        'cafes',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('name', sa.String(), nullable=False),
        sa.Column('timezone', sa.String(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )

    op.create_table(
        'cafe_staff',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('cafe_id', sa.UUID(), nullable=False),
        sa.Column('user_id', sa.UUID(), nullable=False),
        sa.Column('role', staff_role_enum, nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['cafe_id'], ['cafes.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_cafe_staff_cafe_id'), 'cafe_staff', ['cafe_id'], unique=False)
    op.create_index(op.f('ix_cafe_staff_user_id'), 'cafe_staff', ['user_id'], unique=False)

    op.create_table(
        'pc_tiers',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('cafe_id', sa.UUID(), nullable=False),
        sa.Column('name', sa.String(), nullable=False),
        sa.Column('total_quantity', sa.Integer(), nullable=False),
        sa.Column('hourly_rate_paise', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['cafe_id'], ['cafes.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_pc_tiers_cafe_id'), 'pc_tiers', ['cafe_id'], unique=False)

    op.create_table(
        'physical_pcs',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('cafe_id', sa.UUID(), nullable=False),
        sa.Column('tier_id', sa.UUID(), nullable=False),
        sa.Column('pc_number', sa.String(), nullable=False),
        sa.Column('status', pc_status_enum, nullable=False),
        sa.ForeignKeyConstraint(['cafe_id'], ['cafes.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['tier_id'], ['pc_tiers.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_physical_pcs_cafe_id'), 'physical_pcs', ['cafe_id'], unique=False)
    op.create_index(op.f('ix_physical_pcs_tier_id'), 'physical_pcs', ['tier_id'], unique=False)

    op.create_table(
        'bookings',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('cafe_id', sa.UUID(), nullable=False),
        sa.Column('user_id', sa.UUID(), nullable=False),
        sa.Column('tier_id', sa.UUID(), nullable=False),
        sa.Column('booking_time', TSTZRANGE(), nullable=False),
        sa.Column('status', booking_status_enum, nullable=False),
        sa.Column('total_amount_paise', sa.Integer(), nullable=False),
        sa.Column('payment_status', payment_status_enum, nullable=False),
        sa.Column('qr_code_token', sa.String(), nullable=False),
        sa.Column('assigned_pc_id', sa.UUID(), nullable=True),
        sa.Column('claimed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('claimed_by_staff_id', sa.UUID(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['assigned_pc_id'], ['physical_pcs.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['cafe_id'], ['cafes.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['claimed_by_staff_id'], ['cafe_staff.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['tier_id'], ['pc_tiers.id'], ondelete='RESTRICT'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_bookings_assigned_pc_id'), 'bookings', ['assigned_pc_id'], unique=False)
    op.create_index(op.f('ix_bookings_cafe_id'), 'bookings', ['cafe_id'], unique=False)
    op.create_index(op.f('ix_bookings_claimed_by_staff_id'), 'bookings', ['claimed_by_staff_id'], unique=False)
    op.create_index(op.f('ix_bookings_qr_code_token'), 'bookings', ['qr_code_token'], unique=True)
    op.create_index(op.f('ix_bookings_tier_id'), 'bookings', ['tier_id'], unique=False)
    op.create_index(op.f('ix_bookings_user_id'), 'bookings', ['user_id'], unique=False)

    # 4. Create Exclude Constraint using btree_gist
    op.create_exclude_constraint(
        'exclude_overlapping_pcs',
        'bookings',
        ('assigned_pc_id', sa.text('=')),
        ('booking_time', sa.text('&&')),
        where='assigned_pc_id IS NOT NULL',
        using='gist'
    )


def downgrade() -> None:
    # 1. Drop exclude constraint
    op.drop_constraint('exclude_overlapping_pcs', 'bookings', type_='exclude')

    # 2. Drop tables in reverse order of creation
    op.drop_index(op.f('ix_bookings_user_id'), table_name='bookings')
    op.drop_index(op.f('ix_bookings_tier_id'), table_name='bookings')
    op.drop_index(op.f('ix_bookings_qr_code_token'), table_name='bookings')
    op.drop_index(op.f('ix_bookings_claimed_by_staff_id'), table_name='bookings')
    op.drop_index(op.f('ix_bookings_cafe_id'), table_name='bookings')
    op.drop_index(op.f('ix_bookings_assigned_pc_id'), table_name='bookings')
    op.drop_table('bookings')

    op.drop_index(op.f('ix_physical_pcs_tier_id'), table_name='physical_pcs')
    op.drop_index(op.f('ix_physical_pcs_cafe_id'), table_name='physical_pcs')
    op.drop_table('physical_pcs')

    op.drop_index(op.f('ix_pc_tiers_cafe_id'), table_name='pc_tiers')
    op.drop_table('pc_tiers')

    op.drop_index(op.f('ix_cafe_staff_user_id'), table_name='cafe_staff')
    op.drop_index(op.f('ix_cafe_staff_cafe_id'), table_name='cafe_staff')
    op.drop_table('cafe_staff')

    op.drop_table('cafes')

    op.drop_index(op.f('ix_users_email'), table_name='users')
    op.drop_table('users')

    # 3. Drop Custom ENUM Types
    op.execute("DROP TYPE staff_role_enum;")
    op.execute("DROP TYPE pc_status_enum;")
    op.execute("DROP TYPE booking_status_enum;")
    op.execute("DROP TYPE payment_status_enum;")

    # 4. Disable btree_gist extension (optional, usually keep it unless you specifically want to remove it)
    op.execute("DROP EXTENSION IF EXISTS btree_gist;")
