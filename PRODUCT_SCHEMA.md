# Product Table - JSON Schema & Database Design

## Product Table Schema (PostgreSQL + Prisma)

### Prisma Schema Definition

```prisma
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
  
  // Product Details
  weight            Decimal?  @db.Decimal(8, 3) // in kg
  dimensions        Json?     // { length: number, width: number, height: number }
  materials         String?   // e.g., "100% Cotton"
  careInstructions  String?
  
  // Categories & Organization
  category          Category  @relation(fields: [categoryId], references: [id])
  categoryId        String
  tags              String[]  @default([])
  
  // Media
  image             String?   // Primary image URL
  images            String[]  @default([])
  videoUrl          String?
  
  // Variants
  sizes             String[]  @default([])
  colors            String[]  @default([])
  variants          Variant[]
  
  // Status & Metadata
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
  stockMovements    StockMovement[]
  orderItems        OrderItem[]
  reviews           Review[]
  
  @@index([status])
  @@index([categoryId])
  @@index([stockQty])
  @@index([sku])
  @@index([name])
  @@index([featured])
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
}

model Category {
  id          String    @id @default(cuid())
  name        String    @unique
  slug        String    @unique
  description String?
  image       String?
  
  parent      Category? @relation("CategoryHierarchy", fields: [parentId], references: [id])
  parentId    String?
  children    Category[] @relation("CategoryHierarchy")
  products    Product[]
  
  position    Int       @default(0)
  isActive    Boolean   @default(true)
  
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  
  @@index([parentId])
  @@index([isActive])
}
```

### Product Status Enum

```typescript
enum ProductStatus {
  ACTIVE      // Available for sale
  INACTIVE    // Hidden from store
  DRAFT       // Not yet published
  ARCHIVED    // No longer available
  DISCONTINUED // Will not be restocked
}
```

## JSON Schema for Product API

### Create Product Request Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Product",
  "type": "object",
  "required": [
    "name",
    "sku",
    "categoryId",
    "price",
    "costPrice",
    "stockQty",
    "reorderLevel"
  ],
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 200,
      "description": "Product name"
    },
    "sku": {
      "type": "string",
      "pattern": "^[A-Z0-9-]{3,50}$",
      "description": "Unique stock keeping unit"
    },
    "barcode": {
      "type": "string",
      "pattern": "^[0-9]{8,14}$",
      "description": "UPC/EAN barcode"
    },
    "slug": {
      "type": "string",
      "pattern": "^[a-z0-9-]{3,200}$",
      "description": "URL-friendly identifier"
    },
    "description": {
      "type": "string",
      "maxLength": 2000,
      "description": "Detailed product description"
    },
    "shortDescription": {
      "type": "string",
      "maxLength": 500,
      "description": "Brief product summary"
    },
    "price": {
      "type": "number",
      "minimum": 0,
      "multipleOf": 0.01,
      "description": "Selling price"
    },
    "costPrice": {
      "type": "number",
      "minimum": 0,
      "multipleOf": 0.01,
      "description": "Cost price"
    },
    "comparePrice": {
      "type": "number",
      "minimum": 0,
      "multipleOf": 0.01,
      "description": "Original price for comparison"
    },
    "stockQty": {
      "type": "integer",
      "minimum": 0,
      "maximum": 999999,
      "description": "Current stock quantity"
    },
    "reorderLevel": {
      "type": "integer",
      "minimum": 0,
      "maximum": 999999,
      "description": "Stock level at which to reorder"
    },
    "maxStock": {
      "type": "integer",
      "minimum": 1,
      "maximum": 999999,
      "description": "Maximum stock to maintain"
    },
    "weight": {
      "type": "number",
      "minimum": 0,
      "multipleOf": 0.001,
      "description": "Weight in kilograms"
    },
    "dimensions": {
      "type": "object",
      "properties": {
        "length": {
          "type": "number",
          "minimum": 0,
          "multipleOf": 0.1
        },
        "width": {
          "type": "number",
          "minimum": 0,
          "multipleOf": 0.1
        },
        "height": {
          "type": "number",
          "minimum": 0,
          "multipleOf": 0.1
        }
      },
      "required": ["length", "width", "height"]
    },
    "materials": {
      "type": "string",
      "maxLength": 200,
      "description": "Materials composition"
    },
    "careInstructions": {
      "type": "string",
      "maxLength": 1000,
      "description": "Care and washing instructions"
    },
    "categoryId": {
      "type": "string",
      "format": "uuid",
      "description": "Category ID"
    },
    "tags": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 50
      },
      "maxItems": 10,
      "description": "Product tags for search"
    },
    "image": {
      "type": "string",
      "format": "uri",
      "description": "Primary product image URL"
    },
    "images": {
      "type": "array",
      "items": {
        "type": "string",
        "format": "uri"
      },
      "maxItems": 10,
      "description": "Additional product images"
    },
    "videoUrl": {
      "type": "string",
      "format": "uri",
      "description": "Product video URL"
    },
    "sizes": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": ["XS", "S", "M", "L", "XL", "XXL", "3XL", "4XL", "5XL"]
      },
      "maxItems": 10,
      "description": "Available sizes"
    },
    "colors": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 30
      },
      "maxItems": 20,
      "description": "Available colors"
    },
    "status": {
      "type": "string",
      "enum": ["ACTIVE", "INACTIVE", "DRAFT", "ARCHIVED", "DISCONTINUED"],
      "default": "ACTIVE"
    },
    "featured": {
      "type": "boolean",
      "default": false,
      "description": "Featured product"
    },
    "trackInventory": {
      "type": "boolean",
      "default": true,
      "description": "Track inventory levels"
    },
    "allowBackorder": {
      "type": "boolean",
      "default": false,
      "description": "Allow backordering"
    },
    "requiresShipping": {
      "type": "boolean",
      "default": true,
      "description": "Requires shipping"
    },
    "metaTitle": {
      "type": "string",
      "maxLength": 60,
      "description": "SEO title"
    },
    "metaDescription": {
      "type": "string",
      "maxLength": 160,
      "description": "SEO description"
    },
    "metaKeywords": {
      "type": "string",
      "maxLength": 200,
      "description": "SEO keywords"
    },
    "variants": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["sku", "price"],
        "properties": {
          "sku": {
            "type": "string",
            "pattern": "^[A-Z0-9-]{3,50}$"
          },
          "price": {
            "type": "number",
            "minimum": 0,
            "multipleOf": 0.01
          },
          "stockQty": {
            "type": "integer",
            "minimum": 0
          },
          "size": {
            "type": "string"
          },
          "color": {
            "type": "string"
          },
          "image": {
            "type": "string",
            "format": "uri"
          }
        }
      },
      "maxItems": 50,
      "description": "Product variants"
    }
  }
}
```

### Product Response Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Product Response",
  "type": "object",
  "properties": {
    "id": {
      "type": "string",
      "format": "cuid"
    },
    "name": {
      "type": "string"
    },
    "sku": {
      "type": "string"
    },
    "barcode": {
      "type": ["string", "null"]
    },
    "slug": {
      "type": "string"
    },
    "description": {
      "type": ["string", "null"]
    },
    "shortDescription": {
      "type": ["string", "null"]
    },
    "price": {
      "type": "number"
    },
    "costPrice": {
      "type": "number"
    },
    "comparePrice": {
      "type": ["number", "null"]
    },
    "stockQty": {
      "type": "integer"
    },
    "reorderLevel": {
      "type": "integer"
    },
    "maxStock": {
      "type": ["integer", "null"]
    },
    "weight": {
      "type": ["number", "null"]
    },
    "dimensions": {
      "type": ["object", "null"]
    },
    "materials": {
      "type": ["string", "null"]
    },
    "careInstructions": {
      "type": ["string", "null"]
    },
    "category": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string"
        },
        "name": {
          "type": "string"
        },
        "slug": {
          "type": "string"
        }
      }
    },
    "categoryId": {
      "type": "string"
    },
    "tags": {
      "type": "array",
      "items": {
        "type": "string"
      }
    },
    "image": {
      "type": ["string", "null"]
    },
    "images": {
      "type": "array",
      "items": {
        "type": "string"
      }
    },
    "videoUrl": {
      "type": ["string", "null"]
    },
    "sizes": {
      "type": "array",
      "items": {
        "type": "string"
      }
    },
    "colors": {
      "type": "array",
      "items": {
        "type": "string"
      }
    },
    "status": {
      "type": "string",
      "enum": ["ACTIVE", "INACTIVE", "DRAFT", "ARCHIVED", "DISCONTINUED"]
    },
    "featured": {
      "type": "boolean"
    },
    "trackInventory": {
      "type": "boolean"
    },
    "allowBackorder": {
      "type": "boolean"
    },
    "requiresShipping": {
      "type": "boolean"
    },
    "metaTitle": {
      "type": ["string", "null"]
    },
    "metaDescription": {
      "type": ["string", "null"]
    },
    "metaKeywords": {
      "type": ["string", "null"]
    },
    "variants": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id": {
            "type": "string"
          },
          "sku": {
            "type": "string"
          },
          "price": {
            "type": "number"
          },
          "stockQty": {
            "type": "integer"
          },
          "size": {
            "type": ["string", "null"]
          },
          "color": {
            "type": ["string", "null"]
          },
          "image": {
            "type": ["string", "null"]
          }
        }
      }
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time"
    }
  },
  "required": [
    "id",
    "name",
    "sku",
    "slug",
    "price",
    "costPrice",
    "stockQty",
    "reorderLevel",
    "status",
    "categoryId",
    "createdAt",
    "updatedAt"
  ]
}
```

## TypeScript Types

```typescript
// Base Product Type
export interface Product {
  id: string;
  name: string;
  sku: string;
  barcode: string | null;
  slug: string;
  description: string | null;
  shortDescription: string | null;
  
  // Pricing
  price: number;
  costPrice: number;
  comparePrice: number | null;
  
  // Inventory
  stockQty: number;
  reorderLevel: number;
  maxStock: number | null;
  
  // Physical Properties
  weight: number | null;
  dimensions: {
    length: number;
    width: number;
    height: number;
  } | null;
  materials: string | null;
  careInstructions: string | null;
  
  // Organization
  category: Category;
  categoryId: string;
  tags: string[];
  
  // Media
  image: string | null;
  images: string[];
  videoUrl: string | null;
  
  // Variants
  sizes: string[];
  colors: string[];
  variants: Variant[];
  
  // Status & Settings
  status: ProductStatus;
  featured: boolean;
  trackInventory: boolean;
  allowBackorder: boolean;
  requiresShipping: boolean;
  
  // SEO
  metaTitle: string | null;
  metaDescription: string | null;
  metaKeywords: string | null;
  
  // Timestamps
  createdAt: Date;
  updatedAt: Date;
}

export interface Variant {
  id: string;
  productId: string;
  sku: string;
  price: number;
  stockQty: number;
  size: string | null;
  color: string | null;
  image: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  image: string | null;
  parentId: string | null;
  position: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export enum ProductStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  DRAFT = 'DRAFT',
  ARCHIVED = 'ARCHIVED',
  DISCONTINUED = 'DISCONTINUED'
}

// Form Types
export interface CreateProductRequest {
  name: string;
  sku: string;
  barcode?: string;
  slug?: string;
  description?: string;
  shortDescription?: string;
  price: number;
  costPrice: number;
  comparePrice?: number;
  stockQty: number;
  reorderLevel: number;
  maxStock?: number;
  weight?: number;
  dimensions?: {
    length: number;
    width: number;
    height: number;
  };
  materials?: string;
  careInstructions?: string;
  categoryId: string;
  tags?: string[];
  image?: string;
  images?: string[];
  videoUrl?: string;
  sizes?: string[];
  colors?: string[];
  status?: ProductStatus;
  featured?: boolean;
  trackInventory?: boolean;
  allowBackorder?: boolean;
  requiresShipping?: boolean;
  metaTitle?: string;
  metaDescription?: string;
  metaKeywords?: string;
  variants?: {
    sku: string;
    price: number;
    stockQty?: number;
    size?: string;
    color?: string;
    image?: string;
  }[];
}

export interface UpdateProductRequest extends Partial<CreateProductRequest> {}

// API Response Types
export interface ProductListResponse {
  success: boolean;
  data: {
    products: Product[];
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
  };
}

export interface ProductResponse {
  success: boolean;
  data: Product;
}

// Stock Alert Type
export interface StockAlert {
  productId: string;
  productName: string;
  sku: string;
  currentStock: number;
  reorderLevel: number;
  urgency: 'low' | 'medium' | 'high';
  lastUpdated: Date;
}
```

## Database Indexes for Performance

```sql
-- Product Table Indexes
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_stock_qty ON products(stock_qty);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_featured ON products(featured);
CREATE INDEX idx_products_created_at ON products(created_at);

-- Composite Indexes
CREATE INDEX idx_products_status_category ON products(status, category_id);
CREATE INDEX idx_products_stock_status ON products(stock_qty, status);

-- Full-text Search Index
CREATE INDEX idx_products_search ON products USING gin(
  to_tsvector('english', name || ' ' || COALESCE(description, '') || ' ' || COALESCE(sku, ''))
);

-- Variant Table Indexes
CREATE INDEX idx_variants_product_id ON variants(product_id);
CREATE INDEX idx_variants_sku ON variants(sku);

-- Category Table Indexes
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_active ON categories(is_active);
```

This comprehensive schema provides a robust foundation for inventory management with proper validation, relationships, and performance optimization.
