# Staff Admin Panel - API Specification

## Tech Stack
- **Frontend**: React 18, TypeScript, Tailwind CSS, Axios
- **Backend**: Node.js, Express.js, TypeScript, JWT
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT with Role-Based Access Control

## API Endpoints

### 1. Authentication & Authorization

#### POST /api/auth/login
```typescript
// Request Body
{
  email: string;
  password: string;
}

// Response
{
  success: boolean;
  data: {
    token: string;
    user: {
      id: string;
      email: string;
      firstName: string;
      lastName: string;
      role: 'support_staff' | 'manager';
      permissions: string[];
    };
  };
}
```

#### POST /api/auth/refresh
```typescript
// Request Headers
Authorization: Bearer <token>

// Response
{
  success: boolean;
  data: {
    token: string;
  };
}
```

#### POST /api/auth/logout
```typescript
// Request Headers
Authorization: Bearer <token>

// Response
{
  success: boolean;
  message: string;
}
```

### 2. Inventory Management

#### GET /api/inventory/products
```typescript
// Query Parameters
?page=1&limit=20&search=keyword&category=tees&status=active&lowStock=true

// Response
{
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
```

#### POST /api/inventory/products
```typescript
// Request Body
{
  name: string;
  sku: string;
  barcode: string;
  category: string;
  price: number;
  costPrice: number;
  stockQty: number;
  reorderLevel: number;
  status: 'active' | 'inactive';
  description: string;
  images: string[];
  sizes: string[];
  colors: string[];
}

// Response
{
  success: boolean;
  data: Product;
}
```

#### PUT /api/inventory/products/:id
```typescript
// Request Body: Same as POST
// Response: Same as POST
```

#### DELETE /api/inventory/products/:id
```typescript
// Response
{
  success: boolean;
  message: string;
}
```

#### GET /api/inventory/low-stock
```typescript
// Query Parameters
?page=1&limit=20&threshold=10

// Response
{
  success: boolean;
  data: {
    products: Product[];
    alerts: {
      productId: string;
      currentStock: number;
      reorderLevel: number;
      urgency: 'low' | 'medium' | 'high';
    }[];
  };
}
```

#### POST /api/inventory/stock-adjustment
```typescript
// Request Body
{
  productId: string;
  adjustment: number; // Positive for addition, negative for deduction
  reason: string;
  type: 'sale' | 'return' | 'damage' | 'adjustment' | 'purchase';
  notes?: string;
}

// Response
{
  success: boolean;
  data: {
    product: Product;
    movement: StockMovement;
  };
}
```

#### GET /api/inventory/movements
```typescript
// Query Parameters
?productId=id&fromDate=2024-01-01&toDate=2024-12-31&type=sale

// Response
{
  success: boolean;
  data: StockMovement[];
}
```

### 3. Order Processing

#### GET /api/orders
```typescript
// Query Parameters
?page=1&limit=20&status=pending&fromDate=2024-01-01&toDate=2024-12-31&customerId=id

// Response
{
  success: boolean;
  data: {
    orders: Order[];
    pagination: PaginationData;
    stats: {
      total: number;
      pending: number;
      processing: number;
      shipped: number;
      delivered: number;
      cancelled: number;
    };
  };
}
```

#### GET /api/orders/:id
```typescript
// Response
{
  success: boolean;
  data: Order;
}
```

#### PUT /api/orders/:id/status
```typescript
// Request Body
{
  status: 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  notes?: string;
  trackingNumber?: string;
  shippingCarrier?: string;
}

// Response
{
  success: boolean;
  data: Order;
}
```

#### POST /api/orders/:id/ship
```typescript
// Request Body
{
  trackingNumber: string;
  shippingCarrier: string;
  shippingMethod: string;
  estimatedDelivery: string;
  notes?: string;
}

// Response
{
  success: boolean;
  data: {
    order: Order;
    shipment: Shipment;
  };
}
```

#### GET /api/orders/pending-shipment
```typescript
// Query Parameters
?page=1&limit=20&priority=high

// Response
{
  success: boolean;
  data: {
    orders: Order[];
    priorityQueue: {
      high: Order[];
      medium: Order[];
      low: Order[];
    };
  };
}
```

#### POST /api/orders/bulk-update
```typescript
// Request Body
{
  orderIds: string[];
  updates: {
    status?: string;
    notes?: string;
    assignee?: string;
  };
}

// Response
{
  success: boolean;
  data: {
    updated: Order[];
    failed: {
      orderId: string;
      error: string;
    }[];
  };
}
```

### 4. Customer Management

#### GET /api/customers
```typescript
// Query Parameters
?page=1&limit=20&search=keyword&loyaltyTier=gold

// Response
{
  success: boolean;
  data: {
    customers: Customer[];
    pagination: PaginationData;
  };
}
```

#### GET /api/customers/:id
```typescript
// Response
{
  success: boolean;
  data: {
    customer: Customer;
    orders: Order[];
    loyaltyPoints: LoyaltyPoint[];
  };
}
```

#### PUT /api/customers/:id
```typescript
// Request Body
{
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
  loyaltyPoints?: number;
  notes?: string;
}

// Response
{
  success: boolean;
  data: Customer;
}
```

### 5. Role-Based Access Control

#### GET /api/users/staff
```typescript
// Query Parameters
?page=1&limit=20&role=support_staff&status=active

// Response
{
  success: boolean;
  data: {
    staff: StaffUser[];
    pagination: PaginationData;
  };
}
```

#### POST /api/users/staff
```typescript
// Request Body (Manager only)
{
  firstName: string;
  lastName: string;
  email: string;
  role: 'support_staff' | 'manager';
  permissions: string[];
  department: string;
}

// Response
{
  success: boolean;
  data: StaffUser;
}
```

#### PUT /api/users/staff/:id/permissions
```typescript
// Request Body (Manager only)
{
  permissions: string[];
  role?: 'support_staff' | 'manager';
}

// Response
{
  success: boolean;
  data: StaffUser;
}
```

#### GET /api/permissions/roles/:role
```typescript
// Response
{
  success: boolean;
  data: {
    role: string;
    permissions: {
      resource: string;
      actions: ('read' | 'create' | 'update' | 'delete')[];
    }[];
  };
}
```

### 6. Analytics & Reporting

#### GET /api/analytics/dashboard
```typescript
// Query Parameters
?period=7d&metrics=sales,inventory,orders

// Response
{
  success: boolean;
  data: {
    sales: {
      total: number;
      growth: number;
      byDay: { date: string; amount: number }[];
    };
    inventory: {
      totalProducts: number;
      lowStockItems: number;
      outOfStockItems: number;
    };
    orders: {
      total: number;
      pending: number;
      completed: number;
      averageProcessingTime: number;
    };
  };
}
```

#### GET /api/analytics/inventory-report
```typescript
// Query Parameters
?format=csv&fromDate=2024-01-01&toDate=2024-12-31

// Response
{
  success: boolean;
  data: {
    reportUrl?: string;
    data?: InventoryReportData[];
  };
}
```

## Error Response Format

```typescript
{
  success: false;
  error: {
    code: string;
    message: string;
    details?: any;
  };
}
```

## Common Error Codes
- `UNAUTHORIZED` - Invalid or missing token
- `FORBIDDEN` - Insufficient permissions
- `NOT_FOUND` - Resource not found
- `VALIDATION_ERROR` - Invalid input data
- `DUPLICATE_ENTRY` - Resource already exists
- `INTERNAL_ERROR` - Server error
