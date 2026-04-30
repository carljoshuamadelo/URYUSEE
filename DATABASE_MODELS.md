# Database Models & Relationships

## Complete Prisma Schema

```prisma
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ========================================
// USER & AUTHENTICATION MODELS
// ========================================

model User {
  id          String    @id @default(cuid())
  email       String    @unique
  password    String
  firstName   String
  lastName    String
  role        UserRole  @default(SUPPORT_STAFF)
  isActive    Boolean   @default(true)
  lastLoginAt DateTime?
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  // Relations
  permissions UserPermission[]
  stockMovements StockMovement[] @relation("StaffMember")
  createdOrders   Order[]          @relation("CreatedBy")
  updatedOrders   Order[]          @relation("UpdatedBy")
  shipments       Shipment[]
  notifications   Notification[]

  @@map("users")
}

model UserPermission {
  id           String @id @default(cuid())
  userId       String
  permissionId String
  grantedAt    DateTime @default(now())

  // Relations
  user       User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  permission Permission @relation(fields: [permissionId], references: [id], onDelete: Cascade)

  @@unique([userId, permissionId])
  @@map("user_permissions")
}

model Permission {
  id          String   @id @default(cuid())
  name        String   @unique
  description String?
  resource    String
  action      String
  createdAt   DateTime @default(now())

  // Relations
  users UserPermission[]

  @@unique([resource, action])
  @@map("permissions")
}

enum UserRole {
  SUPPORT_STAFF
  MANAGER
  ADMIN
}

// ========================================
// PRODUCT & INVENTORY MODELS
// ========================================

model Category {
  id          String    @id @default(cuid())
  name        String    @unique
  slug        String    @unique
  description String?
  image       String?
  parentId    String?
  position    Int       @default(0)
  isActive    Boolean   @default(true)
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  // Self-referencing hierarchy
  parent      Category? @relation("CategoryHierarchy", fields: [parentId], references: [id])
  children    Category[] @relation("CategoryHierarchy")

  // Relations
  products Product[]

  @@map("categories")
}

model Product {
  id                String    @id @default(cuid())
  name              String
  sku               String    @unique
  barcode           String?   @unique
  slug              String    @unique
  description       String?
  shortDescription  String?
  
  // Pricing
  price             Decimal   @db.Decimal(10, 2)
  costPrice         Decimal   @db.Decimal(10, 2)
  comparePrice      Decimal?  @db.Decimal(10, 2)
  
  // Inventory
  stockQty          Int       @default(0)
  reorderLevel      Int       @default(10)
  maxStock          Int?      @default(1000)
  
  // Physical Properties
  weight            Decimal?  @db.Decimal(8, 3)
  dimensions        Json?     // { length: number, width: number, height: number }
  materials         String?
  careInstructions  String?
  
  // Organization
  category          Category  @relation(fields: [categoryId], references: [id])
  categoryId        String
  tags              String[]  @default([])
  
  // Media
  image             String?
  images            String[]  @default([])
  videoUrl          String?
  
  // Variants
  sizes             String[]  @default([])
  colors            String[]  @default([])
  variants          Variant[]
  
  // Status & Settings
  status            ProductStatus @default(ACTIVE)
  featured          Boolean   @default(false)
  trackInventory    Boolean   @default(true)
  allowBackorder    Boolean   @default(false)
  requiresShipping  Boolean   @default(true)
  
  // SEO
  metaTitle         String?
  metaDescription   String?
  metaKeywords      String?
  
  // Timestamps
  createdAt         DateTime  @default(now())
  updatedAt         DateTime  @updatedAt

  // Relations
  stockMovements StockMovement[]
  orderItems       OrderItem[]
  reviews          Review[]

  @@index([status])
  @@index([categoryId])
  @@index([stockQty])
  @@index([sku])
  @@index([name])
  @@index([featured])
  @@map("products")
}

model Variant {
  id          String  @id @default(cuid())
  productId   String
  product     Product @relation(fields: [productId], references: [id], onDelete: Cascade)
  sku         String  @unique
  price       Decimal @db.Decimal(10, 2)
  stockQty    Int     @default(0)
  size        String?
  color       String?
  image       String?
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  @@index([productId])
  @@index([sku])
  @@map("variants")
}

enum ProductStatus {
  ACTIVE
  INACTIVE
  DRAFT
  ARCHIVED
  DISCONTINUED
}

model StockMovement {
  id          String        @id @default(cuid())
  productId   String
  product     Product       @relation(fields: [productId], references: [id], onDelete: Cascade)
  staffId     String
  staff       User          @relation("StaffMember", fields: [staffId], references: [id])
  
  type        MovementType
  quantity    Int           // Positive for addition, negative for deduction
  reason      String
  notes       String?
  
  // Metadata
  referenceId String?       // Order ID, Purchase Order ID, etc.
  referenceType String?     // 'order', 'purchase', 'adjustment', etc.
  
  createdAt   DateTime      @default(now())

  @@index([productId])
  @@index([staffId])
  @@index([type])
  @@index([createdAt])
  @@map("stock_movements")
}

enum MovementType {
  SALE
  PURCHASE
  RETURN
  DAMAGE
  ADJUSTMENT
  TRANSFER_IN
  TRANSFER_OUT
}

// ========================================
// ORDER & CUSTOMER MODELS
// ========================================

model Customer {
  id            String    @id @default(cuid())
  email         String    @unique
  firstName     String
  lastName      String
  phone         String?
  
  // Address
  billingAddress Json?
  shippingAddress Json?
  
  // Loyalty
  loyaltyPoints Int       @default(0)
  totalSpent    Decimal   @default(0) @db.Decimal(10, 2)
  
  // Preferences
  preferences   Json?     // Email preferences, marketing, etc.
  
  // Status
  isActive      Boolean   @default(true)
  
  // Timestamps
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  // Relations
  orders        Order[]
  reviews       Review[]

  @@index([email])
  @@index([isActive])
  @@map("customers")
}

model Order {
  id              String      @id @default(cuid())
  orderNumber     String      @unique
  customerId      String?
  customer        Customer?   @relation(fields: [customerId], references: [id])
  
  // Customer Details (for guest orders)
  customerName    String?
  customerEmail   String?
  customerPhone   String?
  
  // Pricing
  subtotal        Decimal     @db.Decimal(10, 2)
  taxAmount       Decimal     @default(0) @db.Decimal(10, 2)
  shippingAmount  Decimal     @default(0) @db.Decimal(10, 2)
  discountAmount  Decimal     @default(0) @db.Decimal(10, 2)
  totalAmount     Decimal     @db.Decimal(10, 2)
  
  // Payment
  paymentMethod   PaymentMethod
  paymentStatus   PaymentStatus @default(PENDING)
  paidAt          DateTime?
  
  // Fulfillment
  status          OrderStatus @default(PENDING)
  shippingAddress Json?
  trackingNumber  String?
  shippingCarrier String?
  estimatedDelivery DateTime?
  
  // Staff Assignment
  assignedToId    String?
  assignedTo      User?       @relation("UpdatedBy", fields: [assignedToId], references: [id])
  
  // Audit
  createdById     String?
  createdBy       User?       @relation("CreatedBy", fields: [createdById], references: [id])
  createdAt       DateTime    @default(now())
  updatedAt       DateTime    @updatedAt
  
  // Relations
  items           OrderItem[]
  shipments       Shipment[]
  statusHistory   OrderStatusHistory[]
  notifications   Notification[]

  @@index([customerId])
  @@index([status])
  @@index([paymentStatus])
  @@index([createdAt])
  @@index([orderNumber])
  @@map("orders")
}

model OrderItem {
  id          String  @id @default(cuid())
  orderId     String
  order       Order   @relation(fields: [orderId], references: [id], onDelete: Cascade)
  productId   String
  product     Product @relation(fields: [productId], references: [id])
  
  name        String  // Product snapshot
  sku         String  // Product SKU snapshot
  price       Decimal @db.Decimal(10, 2) // Price at time of purchase
  quantity    Int
  total       Decimal @db.Decimal(10, 2)
  
  createdAt   DateTime @default(now())

  @@index([orderId])
  @@index([productId])
  @@map("order_items")
}

model OrderStatusHistory {
  id          String      @id @default(cuid())
  orderId     String
  order       Order       @relation(fields: [orderId], references: [id], onDelete: Cascade)
  
  fromStatus  OrderStatus?
  toStatus    OrderStatus
  reason      String?
  notes       String?
  
  staffId     String?
  staff       User?       @relation(fields: [staffId], references: [id])
  
  createdAt   DateTime    @default(now())

  @@index([orderId])
  @@index([createdAt])
  @@map("order_status_history")
}

enum OrderStatus {
  PENDING
  CONFIRMED
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
  REFUNDED
}

enum PaymentMethod {
  CASH
  CARD
  BANK_TRANSFER
  DIGITAL_WALLET
  CRYPTOCURRENCY
}

enum PaymentStatus {
  PENDING
  PAID
  FAILED
  REFUNDED
  PARTIALLY_REFUNDED
}

// ========================================
// SHIPPING & FULFILLMENT MODELS
// ========================================

model Shipment {
  id              String      @id @default(cuid())
  orderId         String
  order           Order       @relation(fields: [orderId], references: [id], onDelete: Cascade)
  
  trackingNumber  String      @unique
  carrier         String
  service         String?     // Express, Standard, etc.
  
  // Addresses
  originAddress   Json
  destinationAddress Json
  
  // Timeline
  shippedAt        DateTime    @default(now())
  estimatedDelivery DateTime?
  deliveredAt      DateTime?
  
  // Staff
  staffId         String
  staff           User        @relation(fields: [staffId], references: [id])
  
  // Status
  status          ShipmentStatus @default(PREPARING)
  
  createdAt       DateTime    @default(now())
  updatedAt       DateTime    @updatedAt

  // Relations
  trackingEvents  TrackingEvent[]

  @@index([orderId])
  @@index([trackingNumber])
  @@index([status])
  @@map("shipments")
}

model TrackingEvent {
  id          String      @id @default(cuid())
  shipmentId  String
  shipment    Shipment    @relation(fields: [shipmentId], references: [id], onDelete: Cascade)
  
  status      String
  location    String?
  description String?
  timestamp   DateTime    @default(now())

  @@index([shipmentId])
  @@index([timestamp])
  @@map("tracking_events")
}

enum ShipmentStatus {
  PREPARING
  SHIPPED
  IN_TRANSIT
  OUT_FOR_DELIVERY
  DELIVERED
  EXCEPTION
  RETURNED
}

// ========================================
// NOTIFICATION MODELS
// ========================================

model Notification {
  id        String           @id @default(cuid())
  userId    String
  user      User             @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  title     String
  message   String
  type      NotificationType
  
  // Related Entity
  entityId  String?          // Order ID, Product ID, etc.
  entityType String?          // 'order', 'product', 'customer', etc.
  
  // Status
  isRead    Boolean          @default(false)
  readAt    DateTime?
  
  createdAt DateTime         @default(now())

  @@index([userId])
  @@index([isRead])
  @@index([type])
  @@index([createdAt])
  @@map("notifications")
}

enum NotificationType {
  ORDER_CREATED
  ORDER_UPDATED
  ORDER_SHIPPED
  ORDER_DELIVERED
  ORDER_CANCELLED
  LOW_STOCK
  OUT_OF_STOCK
  PRICE_CHANGE
  CUSTOMER_REGISTERED
  SYSTEM_ALERT
  STAFF_ASSIGNED
}

// ========================================
// REVIEW & FEEDBACK MODELS
// ========================================

model Review {
  id          String    @id @default(cuid())
  productId   String
  product     Product   @relation(fields: [productId], references: [id], onDelete: Cascade)
  customerId  String
  customer    Customer  @relation(fields: [customerId], references: [id])
  
  rating      Int       // 1-5 stars
  title       String?
  content     String?
  
  // Status
  isApproved  Boolean   @default(false)
  isVerified  Boolean   @default(false)
  
  // Metadata
  ipAddress   String?
  userAgent   String?
  
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  @@unique([productId, customerId])
  @@index([productId])
  @@index([customerId])
  @@index([rating])
  @@index([isApproved])
  @@map("reviews")
}

// ========================================
// SYSTEM & ANALYTICS MODELS
// ========================================

model SystemLog {
  id        String    @id @default(cuid())
  level     LogLevel
  message   String
  context   Json?     // Additional context data
  userId    String?   // User who performed the action
  ipAddress String?
  userAgent String?
  createdAt DateTime  @default(now())

  @@index([level])
  @@index([userId])
  @@index([createdAt])
  @@map("system_logs")
}

enum LogLevel {
  DEBUG
  INFO
  WARN
  ERROR
  FATAL
}

model AnalyticsEvent {
  id        String    @id @default(cuid())
  event     String    // 'order_created', 'product_viewed', etc.
  data      Json?     // Event data
  userId    String?   // User who triggered the event
  sessionId String?   // Session identifier
  ipAddress String?
  userAgent String?
  createdAt DateTime  @default(now())

  @@index([event])
  @@index([userId])
  @@index([createdAt])
  @@map("analytics_events")
}
```

## Model Relationships Overview

### User & Authentication
- **User** ↔ **UserPermission** ↔ **Permission** (Many-to-Many)
- **User** creates **StockMovement**, **Order**, **Shipment**, **Notification**

### Product & Inventory
- **Category** ↔ **Product** (One-to-Many, Self-referencing)
- **Product** ↔ **Variant** (One-to-Many)
- **Product** ↔ **StockMovement** (One-to-Many)
- **Product** ↔ **OrderItem** (One-to-Many)
- **Product** ↔ **Review** (One-to-Many)

### Order Management
- **Customer** ↔ **Order** (One-to-Many)
- **Order** ↔ **OrderItem** (One-to-Many)
- **Order** ↔ **Shipment** (One-to-Many)
- **Order** ↔ **OrderStatusHistory** (One-to-Many)
- **Order** ↔ **Notification** (One-to-Many)
- **Product** ↔ **OrderItem** (One-to-Many)

### Shipping & Fulfillment
- **Shipment** ↔ **TrackingEvent** (One-to-Many)
- **Order** ↔ **Shipment** (One-to-Many)

### Reviews & Feedback
- **Customer** ↔ **Review** (One-to-Many)
- **Product** ↔ **Review** (One-to-Many)

### System & Analytics
- **User** ↔ **SystemLog** (One-to-Many)
- **AnalyticsEvent** (Standalone with optional user reference)

## Database Indexes Strategy

### Performance Indexes
```sql
-- User indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active);

-- Product indexes
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_stock ON products(stock_qty);
CREATE INDEX idx_products_featured ON products(featured);
CREATE INDEX idx_products_search ON products USING gin(to_tsvector('english', name || ' ' || COALESCE(description, '') || ' ' || sku));

-- Order indexes
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment ON orders(payment_status);
CREATE INDEX idx_orders_created ON orders(created_at);
CREATE INDEX idx_orders_number ON orders(order_number);

-- Stock movement indexes
CREATE INDEX idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX idx_stock_movements_staff ON stock_movements(staff_id);
CREATE INDEX idx_stock_movements_type ON stock_movements(type);
CREATE INDEX idx_stock_movements_created ON stock_movements(created_at);

-- Composite indexes for common queries
CREATE INDEX idx_orders_status_created ON orders(status, created_at);
CREATE INDEX idx_products_category_status ON products(category_id, status);
CREATE INDEX idx_stock_movements_product_created ON stock_movements(product_id, created_at);
```

## Data Validation Rules

### Business Logic Constraints
```typescript
// Product Validation
- SKU must be unique and follow format: [A-Z0-9-]{3,50}
- Price must be >= 0
- Stock quantity must be >= 0
- Reorder level must be >= 0
- Category must exist and be active

// Order Validation
- Order number must be unique
- Total amount must equal sum of items + tax + shipping - discount
- Customer must exist or guest order details must be complete
- Payment method must be valid enum value

// Stock Movement Validation
- Quantity cannot be 0
- Stock quantity cannot go negative (unless allowBackorder)
- Staff member must exist and be active

// User Validation
- Email must be unique and valid format
- Password must meet security requirements
- Role must be valid enum value
```

## Migration Strategy

### Initial Setup
```typescript
// prisma/migrations/001_initial_setup.sql
-- Create database
CREATE DATABASE staff_admin_panel;

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search

-- Create indexes for full-text search
CREATE INDEX idx_products_search_vector ON products USING gin(to_tsvector('english', name || ' ' || COALESCE(description, '')));
```

### Seed Data Strategy
```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client';
import { UserRole, ProductStatus, OrderStatus } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Create default permissions
  const permissions = await createDefaultPermissions();
  
  // Create admin user
  const adminUser = await createAdminUser();
  
  // Create default categories
  const categories = await createDefaultCategories();
  
  // Create sample products
  const products = await createSampleProducts(categories);
  
  // Create sample customers
  const customers = await createSampleCustomers();
  
  // Create sample orders
  await createSampleOrders(customers, products);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

## Backup & Recovery Strategy

### Automated Backups
```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/staff_admin_panel"
DB_NAME="staff_admin_panel"

# Create backup directory
mkdir -p $BACKUP_DIR

# Full backup
pg_dump -h localhost -U postgres -d $DB_NAME > $BACKUP_DIR/full_backup_$DATE.sql

# Compress backup
gzip $BACKUP_DIR/full_backup_$DATE.sql

# Keep only last 30 days of backups
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete
```

### Recovery Procedures
```bash
#!/bin/bash
# restore.sh
BACKUP_FILE=$1
DB_NAME="staff_admin_panel"

# Drop existing database
dropdb -h localhost -U postgres $DB_NAME

# Create new database
createdb -h localhost -U postgres $DB_NAME

# Restore from backup
gunzip -c $BACKUP_FILE | psql -h localhost -U postgres -d $DB_NAME
```

This comprehensive database schema provides:

1. **Complete data model** for all admin panel features
2. **Proper relationships** with foreign key constraints
3. **Performance optimization** with strategic indexes
4. **Data integrity** with validation rules
5. **Audit trails** with created/updated timestamps
6. **Scalable architecture** ready for high-volume operations
7. **Backup and recovery** procedures
8. **Migration strategy** for database versioning

The schema is designed to support all the features outlined in the API specification while maintaining data consistency and performance at scale.
