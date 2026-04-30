# Staff Admin Panel - Project Directory Structure

## Monorepo Structure

```
staff-admin-panel/
├── README.md
├── package.json
├── docker-compose.yml
├── .env.example
├── .gitignore
├── 
├── frontend/                          # React Frontend
│   ├── public/
│   │   ├── index.html
│   │   ├── favicon.ico
│   │   └── manifest.json
│   ├── src/
│   │   ├── components/               # Reusable UI Components
│   │   │   ├── ui/                  # Base UI Components
│   │   │   │   ├── button.tsx
│   │   │   │   ├── input.tsx
│   │   │   │   ├── table.tsx
│   │   │   │   ├── modal.tsx
│   │   │   │   ├── badge.tsx
│   │   │   │   ├── select.tsx
│   │   │   │   ├── dialog.tsx
│   │   │   │   ├── sheet.tsx
│   │   │   │   └── index.ts
│   │   │   ├── layout/              # Layout Components
│   │   │   │   ├── Header.tsx
│   │   │   │   ├── Sidebar.tsx
│   │   │   │   ├── Footer.tsx
│   │   │   │   └── Layout.tsx
│   │   │   ├── forms/               # Form Components
│   │   │   │   ├── ProductForm.tsx
│   │   │   │   ├── CustomerForm.tsx
│   │   │   │   ├── OrderForm.tsx
│   │   │   │   └── UserForm.tsx
│   │   │   └── common/              # Common Components
│   │   │       ├── SearchBar.tsx
│   │   │       ├── FilterPanel.tsx
│   │   │       ├── StatusBadge.tsx
│   │   │       ├── ActionButtons.tsx
│   │   │       └── LoadingSpinner.tsx
│   │   ├── pages/                   # Page Components
│   │   │   ├── Dashboard/
│   │   │   │   ├── index.tsx
│   │   │   │   ├── components/
│   │   │   │   │   ├── KPICards.tsx
│   │   │   │   │   ├── RecentOrders.tsx
│   │   │   │   │   ├── LowStockAlerts.tsx
│   │   │   │   │   └── QuickActions.tsx
│   │   │   ├── Inventory/
│   │   │   │   ├── index.tsx
│   │   │   │   ├── ProductList.tsx
│   │   │   │   ├── StockMovements.tsx
│   │   │   │   ├── LowStockItems.tsx
│   │   │   │   └── components/
│   │   │   ├── Orders/
│   │   │   │   ├── index.tsx
│   │   │   │   ├── OrderList.tsx
│   │   │   │   ├── OrderDetails.tsx
│   │   │   │   ├── PendingShipment.tsx
│   │   │   │   └── components/
│   │   │   ├── Customers/
│   │   │   │   ├── index.tsx
│   │   │   │   ├── CustomerList.tsx
│   │   │   │   ├── CustomerDetails.tsx
│   │   │   │   └── components/
│   │   │   ├── Staff/
│   │   │   │   ├── index.tsx
│   │   │   │   ├── StaffList.tsx
│   │   │   │   ├── RoleManagement.tsx
│   │   │   │   └── components/
│   │   │   ├── Analytics/
│   │   │   │   ├── index.tsx
│   │   │   │   ├── Reports.tsx
│   │   │   │   ├── Metrics.tsx
│   │   │   │   └── components/
│   │   │   ├── Settings/
│   │   │   │   ├── index.tsx
│   │   │   │   ├── Profile.tsx
│   │   │   │   └── components/
│   │   │   └── Auth/
│   │   │       ├── Login.tsx
│   │   │       ├── ForgotPassword.tsx
│   │   │       └── ResetPassword.tsx
│   │   ├── hooks/                    # Custom Hooks
│   │   │   ├── useAuth.ts
│   │   │   ├── usePermissions.ts
│   │   │   ├── useInventory.ts
│   │   │   ├── useOrders.ts
│   │   │   ├── useCustomers.ts
│   │   │   └── useAnalytics.ts
│   │   ├── services/                # API Services
│   │   │   ├── api.ts               # Axios configuration
│   │   │   ├── auth.ts
│   │   │   ├── inventory.ts
│   │   │   ├── orders.ts
│   │   │   ├── customers.ts
│   │   │   ├── staff.ts
│   │   │   └── analytics.ts
│   │   ├── store/                   # State Management
│   │   │   ├── index.ts
│   │   │   ├── authSlice.ts
│   │   │   ├── inventorySlice.ts
│   │   │   ├── ordersSlice.ts
│   │   │   └── uiSlice.ts
│   │   ├── types/                   # TypeScript Types
│   │   │   ├── auth.ts
│   │   │   ├── inventory.ts
│   │   │   ├── orders.ts
│   │   │   ├── customers.ts
│   │   │   ├── staff.ts
│   │   │   └── common.ts
│   │   ├── utils/                   # Utility Functions
│   │   │   ├── constants.ts
│   │   │   ├── helpers.ts
│   │   │   ├── formatters.ts
│   │   │   ├── validators.ts
│   │   │   └── permissions.ts
│   │   ├── styles/                  # Styling
│   │   │   ├── globals.css
│   │   │   ├── components.css
│   │   │   └── themes/
│   │   │       ├── light.css
│   │   │       └── dark.css
│   │   ├── App.tsx
│   │   ├── main.tsx
│   │   └── vite-env.d.ts
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   ├── postcss.config.js
│   └── .env.local
│
├── backend/                           # Node.js Backend
│   ├── src/
│   │   ├── controllers/              # Route Controllers
│   │   │   ├── authController.ts
│   │   │   ├── inventoryController.ts
│   │   │   ├── ordersController.ts
│   │   │   ├── customersController.ts
│   │   │   ├── staffController.ts
│   │   │   └── analyticsController.ts
│   │   ├── middleware/               # Express Middleware
│   │   │   ├── auth.ts
│   │   │   ├── permissions.ts
│   │   │   ├── validation.ts
│   │   │   ├── errorHandler.ts
│   │   │   └── rateLimiter.ts
│   │   ├── models/                  # Database Models
│   │   │   ├── User.ts
│   │   │   ├── Product.ts
│   │   │   ├── Order.ts
│   │   │   ├── Customer.ts
│   │   │   ├── StockMovement.ts
│   │   │   ├── Shipment.ts
│   │   │   └── Permission.ts
│   │   ├── routes/                   # API Routes
│   │   │   ├── index.ts
│   │   │   ├── auth.ts
│   │   │   ├── inventory.ts
│   │   │   ├── orders.ts
│   │   │   ├── customers.ts
│   │   │   ├── staff.ts
│   │   │   └── analytics.ts
│   │   ├── services/                 # Business Logic
│   │   │   ├── authService.ts
│   │   │   ├── inventoryService.ts
│   │   │   ├── ordersService.ts
│   │   │   ├── customersService.ts
│   │   │   ├── staffService.ts
│   │   │   ├── emailService.ts
│   │   │   └── analyticsService.ts
│   │   ├── utils/                    # Utility Functions
│   │   │   ├── database.ts
│   │   │   ├── logger.ts
│   │   │   ├── validators.ts
│   │   │   ├── helpers.ts
│   │   │   └── constants.ts
│   │   ├── types/                    # TypeScript Types
│   │   │   ├── auth.ts
│   │   │   ├── inventory.ts
│   │   │   ├── orders.ts
│   │   │   ├── customers.ts
│   │   │   ├── staff.ts
│   │   │   └── common.ts
│   │   ├── config/                   # Configuration
│   │   │   ├── database.ts
│   │   │   ├── jwt.ts
│   │   │   ├── email.ts
│   │   │   └── app.ts
│   │   ├── tests/                    # Test Files
│   │   │   ├── unit/
│   │   │   ├── integration/
│   │   │   └── fixtures/
│   │   ├── app.ts                    # Express App
│   │   └── server.ts                 # Server Entry Point
│   ├── prisma/                       # Prisma ORM
│   │   ├── schema.prisma
│   │   ├── migrations/
│   │   └── seed.ts
│   ├── uploads/                      # File Uploads
│   │   ├── products/
│   │   ├── documents/
│   │   └── temp/
│   ├── logs/                         # Application Logs
│   ├── package.json
│   ├── tsconfig.json
│   ├── jest.config.js
│   ├── .env.example
│   └── .env
│
├── shared/                           # Shared Types & Utilities
│   ├── types/
│   │   ├── api.ts
│   │   ├── database.ts
│   │   └── common.ts
│   ├── utils/
│   │   ├── validation.ts
│   │   ├── constants.ts
│   │   └── helpers.ts
│   └── package.json
│
├── docs/                            # Documentation
│   ├── api/
│   │   ├── authentication.md
│   │   ├── inventory.md
│   │   ├── orders.md
│   │   └── customers.md
│   ├── deployment/
│   │   ├── docker.md
│   │   ├── production.md
│   │   └── monitoring.md
│   ├── development/
│   │   ├── setup.md
│   │   ├── coding-standards.md
│   │   └── testing.md
│   └── user-guides/
│       ├── staff-manual.md
│       └── manager-manual.md
│
└── scripts/                         # Build & Deployment Scripts
    ├── build.sh
    ├── deploy.sh
    ├── backup.sh
    └── seed-data.ts
```

## Key Files Description

### Frontend Key Files

- **`src/components/ui/`** - Reusable base UI components (Button, Input, Table, etc.)
- **`src/pages/`** - Main application pages organized by feature
- **`src/hooks/`** - Custom React hooks for API calls and state management
- **`src/services/`** - API service layer for backend communication
- **`src/store/`** - Redux/Context store for global state management
- **`src/types/`** - TypeScript type definitions
- **`src/utils/`** - Utility functions and constants

### Backend Key Files

- **`src/controllers/`** - HTTP request handlers
- **`src/middleware/`** - Express middleware (auth, validation, error handling)
- **`src/models/`** - Database models using Prisma
- **`src/routes/`** - API route definitions
- **`src/services/`** - Business logic and data processing
- **`prisma/schema.prisma`** - Database schema definition
- **`src/config/`** - Application configuration

### Shared Resources

- **`shared/types/`** - Common TypeScript types used by both frontend and backend
- **`shared/utils/`** - Shared utility functions
- **`docs/`** - Comprehensive documentation

## Development Workflow

1. **Frontend Development**: `cd frontend && npm run dev`
2. **Backend Development**: `cd backend && npm run dev`
3. **Database Setup**: `cd backend && npx prisma migrate dev`
4. **Testing**: `npm run test` (runs both frontend and backend tests)
5. **Build**: `npm run build` (builds both frontend and backend)
6. **Docker**: `docker-compose up` (runs entire stack)

## Environment Variables

### Frontend (.env.local)
```
VITE_API_BASE_URL=http://localhost:3001/api
VITE_APP_NAME=Staff Admin Panel
VITE_APP_VERSION=1.0.0
```

### Backend (.env)
```
NODE_ENV=development
PORT=3001
DATABASE_URL=postgresql://user:password@localhost:5432/staff_admin
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=24h
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
```

This structure provides a scalable, maintainable foundation for a professional staff admin panel with clear separation of concerns and comprehensive tooling.
