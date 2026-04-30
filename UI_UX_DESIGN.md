# Staff Admin Panel - UI/UX Design Specification

## Design Philosophy

**High-Efficiency, Action-Oriented Interface**
The staff panel prioritizes actionable data and quick decision-making for staff working extended shifts. The design minimizes cognitive load while maximizing productivity.

## Color Palette - Eye-Friendly for Extended Use

### Primary Colors
```css
/* Neutral Base - Reduced Eye Strain */
--background-primary: #f8fafc;      /* Very light gray - easy on eyes */
--background-secondary: #ffffff;    /* Clean white for content areas */
--background-tertiary: #f1f5f9;     /* Subtle contrast */

/* Text Colors */
--text-primary: #1e293b;            /* Dark gray - high contrast */
--text-secondary: #64748b;          /* Medium gray - secondary info */
--text-muted: #94a3b8;             /* Light gray - hints/disabled */

/* Accent Colors - Calm but Clear */
--primary-blue: #3b82f6;           /* Main actions */
--primary-green: #10b981;          /* Success states */
--primary-amber: #f59e0b;          /* Warnings/alerts */
--primary-red: #ef4444;            /* Error/danger */

/* Status Colors - Muted for Long Sessions */
--status-pending: #fbbf24;         /* Soft yellow */
--status-processing: #60a5fa;      /* Soft blue */
--status-shipped: #34d399;         /* Soft green */
--status-delivered: #10b981;       /* Clear green */
--status-cancelled: #f87171;       /* Soft red */
```

### Dark Mode Support
```css
/* Dark Mode - Reduced Blue Light */
--dark-background: #0f172a;
--dark-surface: #1e293b;
--dark-border: #334155;
--dark-text-primary: #f8fafc;
--dark-text-secondary: #cbd5e1;
```

## Layout Architecture

### 1. Main Layout Structure

```
┌─────────────────────────────────────────────────────────────┐
│                        Header                              │
│  Logo | Breadcrumb | Search Bar | Notifications | User   │
├─────────────────────────────────────────────────────────────┤
│ Side │                                                    │
│ bar  │                Main Content Area                   │
│      │                                                    │
│ Nav  │  ┌─────────────────────────────────────────────┐   │
│      │  │              Action Toolbar                 │   │
│      │  │  [Filter] [Export] [Bulk Actions] [+]      │   │
│      │  └─────────────────────────────────────────────┘   │
│      │                                                    │
│      │  ┌─────────────────────────────────────────────┐   │
│      │  │            Priority Alerts                   │   │
│      │  │  🔴 Urgent: 5 orders pending shipment       │   │
│      │  │  🟡 Warning: 12 items low stock             │   │
│      │  └─────────────────────────────────────────────┘   │
│      │                                                    │
│      │  ┌─────────────────────────────────────────────┐   │
│      │  │              Data Table                    │   │
│      │  │  ┌─────┬─────┬──────┬──────┬──────┐        │   │
│      │  │  │ ID  │ Name│Status│ Action│ ⋯    │        │   │
│      │  │  └─────┴─────┴──────┴──────┴──────┘        │   │
│      │  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 2. Sidebar Navigation

#### Structure
```typescript
interface SidebarItem {
  id: string;
  label: string;
  icon: LucideIcon;
  badge?: number;
  children?: SidebarItem[];
  permissions?: string[];
}

const sidebarItems: SidebarItem[] = [
  {
    id: 'dashboard',
    label: 'Dashboard',
    icon: LayoutDashboard,
    permissions: ['dashboard.read']
  },
  {
    id: 'catalog',
    label: 'Catalog',
    icon: Package,
    children: [
      {
        id: 'products',
        label: 'Products',
        icon: Box,
        badge: 5, // Low stock items
        permissions: ['products.read']
      },
      {
        id: 'categories',
        label: 'Categories',
        icon: Tags,
        permissions: ['categories.read']
      },
      {
        id: 'inventory',
        label: 'Inventory',
        icon: PackageOpen,
        permissions: ['inventory.read']
      }
    ]
  },
  {
    id: 'orders',
    label: 'Orders',
    icon: ShoppingCart,
    badge: 12, // Pending orders
    children: [
      {
        id: 'order-list',
        label: 'All Orders',
        icon: List,
        permissions: ['orders.read']
      },
      {
        id: 'pending-shipment',
        label: 'Pending Shipment',
        icon: Truck,
        badge: 8,
        permissions: ['orders.ship']
      },
      {
        id: 'returns',
        label: 'Returns',
        icon: RotateCcw,
        permissions: ['orders.returns']
      }
    ]
  },
  {
    id: 'customers',
    label: 'Customers',
    icon: Users,
    children: [
      {
        id: 'customer-list',
        label: 'Customer List',
        icon: UserList,
        permissions: ['customers.read']
      },
      {
        id: 'segments',
        label: 'Segments',
        icon: Target,
        permissions: ['customers.segments']
      }
    ]
  },
  {
    id: 'marketing',
    label: 'Marketing',
    icon: Megaphone,
    permissions: ['marketing.read'],
    children: [
      {
        id: 'campaigns',
        label: 'Campaigns',
        icon: Send,
        permissions: ['marketing.campaigns']
      },
      {
        id: 'promotions',
        label: 'Promotions',
        icon: Tag,
        permissions: ['marketing.promotions']
      }
    ]
  },
  {
    id: 'analytics',
    label: 'Analytics',
    icon: BarChart3,
    permissions: ['analytics.read']
  },
  {
    id: 'settings',
    label: 'Settings',
    icon: Settings,
    children: [
      {
        id: 'staff',
        label: 'Staff Management',
        icon: Users,
        permissions: ['staff.manage']
      },
      {
        id: 'system',
        label: 'System',
        icon: Cog,
        permissions: ['system.admin']
      }
    ]
  }
];
```

### 3. Universal Search Bar

#### Design Specifications
```typescript
interface SearchConfig {
  placeholder: string;
  searchableEntities: {
    orders: {
      fields: ['id', 'customerEmail', 'customerName'];
      placeholder: 'Search Order ID, Customer Email...';
    };
    products: {
      fields: ['sku', 'name', 'barcode'];
      placeholder: 'Search SKU, Product Name, Barcode...';
    };
    customers: {
      fields: ['email', 'name', 'phone'];
      placeholder: 'Search Customer Email, Name, Phone...';
    };
  };
  shortcuts: {
    'ctrl+k': 'Open search';
    'ctrl+shift+o': 'Search orders';
    'ctrl+shift+p': 'Search products';
    'ctrl+shift+c': 'Search customers';
  };
}
```

#### Search Component
```tsx
const UniversalSearch = () => {
  const [query, setQuery] = useState('');
  const [category, setCategory] = useState<'all' | 'orders' | 'products' | 'customers'>('all');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="relative max-w-2xl">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
        <Input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search Order ID, Customer Email, or SKU... (⌘K)"
          className="pl-10 pr-12 h-10 bg-white border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        />
        <div className="absolute right-2 top-1/2 transform -translate-y-1/2 flex gap-1">
          <Badge variant="outline" className="text-xs">
            {category === 'all' ? 'All' : category.charAt(0).toUpperCase() + category.slice(1)}
          </Badge>
        </div>
      </div>
      
      {isOpen && results.length > 0 && (
        <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-gray-200 rounded-lg shadow-lg z-50 max-h-96 overflow-y-auto">
          {/* Search results */}
        </div>
      )}
    </div>
  );
};
```

## Key UI Components

### 1. Data Tables

#### Enhanced Table Component
```tsx
interface DataTableProps<T> {
  data: T[];
  columns: ColumnDef<T>[];
  searchable?: boolean;
  filterable?: boolean;
  sortable?: boolean;
  pagination?: boolean;
  selectable?: boolean;
  bulkActions?: BulkAction[];
  loading?: boolean;
  error?: string;
}

const DataTable = <T,>({ data, columns, ...props }: DataTableProps<T>) => {
  return (
    <div className="bg-white rounded-lg border border-gray-200">
      {/* Table Header with Search & Filters */}
      <div className="p-4 border-b border-gray-200">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <SearchInput placeholder="Search..." />
            <FilterDropdown />
          </div>
          <div className="flex items-center gap-2">
            <Button variant="outline" size="sm">
              <Download className="h-4 w-4 mr-2" />
              Export
            </Button>
            <Button size="sm">
              <Plus className="h-4 w-4 mr-2" />
              Add New
            </Button>
          </div>
        </div>
      </div>
      
      {/* Table Content */}
      <div className="overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow className="bg-gray-50 border-b border-gray-200">
              {columns.map((column) => (
                <TableHead 
                  key={column.id}
                  className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  <div className="flex items-center gap-1">
                    <span>{column.header}</span>
                    {column.sortable && <ChevronDown className="h-3 w-3" />}
                  </div>
                </TableHead>
              ))}
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.map((row, index) => (
              <TableRow 
                key={row.id}
                className="border-b border-gray-100 hover:bg-gray-50 transition-colors"
              >
                {columns.map((column) => (
                  <TableCell key={column.id} className="px-4 py-3">
                    {column.cell(row, index)}
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
      
      {/* Pagination */}
      {props.pagination && (
        <div className="p-4 border-t border-gray-200">
          <Pagination />
        </div>
      )}
    </div>
  );
};
```

### 2. Status Badges

#### Status Badge Component
```tsx
interface StatusBadgeProps {
  status: string;
  variant?: 'default' | 'success' | 'warning' | 'error' | 'info';
  size?: 'sm' | 'md' | 'lg';
  showIcon?: boolean;
}

const StatusBadge = ({ status, variant = 'default', size = 'md', showIcon = true }: StatusBadgeProps) => {
  const getStatusConfig = (status: string) => {
    const configs: Record<string, { variant: string; icon: LucideIcon; color: string }> = {
      'pending': { variant: 'warning', icon: Clock, color: 'text-amber-600' },
      'processing': { variant: 'info', icon: Package, color: 'text-blue-600' },
      'shipped': { variant: 'default', icon: Truck, color: 'text-purple-600' },
      'delivered': { variant: 'success', icon: CheckCircle, color: 'text-green-600' },
      'cancelled': { variant: 'error', icon: XCircle, color: 'text-red-600' },
      'active': { variant: 'success', icon: CheckCircle, color: 'text-green-600' },
      'inactive': { variant: 'default', icon: XCircle, color: 'text-gray-600' },
      'low-stock': { variant: 'warning', icon: AlertTriangle, color: 'text-amber-600' },
      'out-of-stock': { variant: 'error', icon: XCircle, color: 'text-red-600' }
    };
    
    return configs[status] || { variant: 'default', icon: Circle, color: 'text-gray-600' };
  };

  const config = getStatusConfig(status);
  const Icon = config.icon;

  return (
    <Badge 
      variant={variant} 
      className={cn(
        "flex items-center gap-1 font-medium",
        config.color,
        size === 'sm' && "text-xs px-2 py-1",
        size === 'md' && "text-sm px-3 py-1.5",
        size === 'lg' && "text-base px-4 py-2"
      )}
    >
      {showIcon && <Icon className="h-3 w-3" />}
      {status.replace('-', ' ').toUpperCase()}
    </Badge>
  );
};
```

### 3. Modal Pop-ups

#### Modal Component System
```tsx
interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'full';
  children: React.ReactNode;
  footer?: React.ReactNode;
}

const Modal = ({ isOpen, onClose, title, size = 'md', children, footer }: ModalProps) => {
  const sizeClasses = {
    sm: 'max-w-md',
    md: 'max-w-lg',
    lg: 'max-w-2xl',
    xl: 'max-w-4xl',
    full: 'max-w-7xl'
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className={cn("bg-white border border-gray-200 shadow-xl", sizeClasses[size])}>
        <DialogHeader className="border-b border-gray-200 pb-4">
          <DialogTitle className="text-lg font-semibold text-gray-900">{title}</DialogTitle>
        </DialogHeader>
        
        <div className="py-6">
          {children}
        </div>
        
        {footer && (
          <DialogFooter className="border-t border-gray-200 pt-4">
            {footer}
          </DialogFooter>
        )}
      </DialogContent>
    </Dialog>
  );
};
```

### 4. Action Buttons

#### Action Button Component
```tsx
interface ActionButtonProps {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  icon?: LucideIcon;
  label?: string;
  loading?: boolean;
  disabled?: boolean;
  onClick?: () => void;
}

const ActionButton = ({ 
  variant = 'primary', 
  size = 'md', 
  icon: Icon, 
  label, 
  loading = false, 
  disabled = false,
  onClick 
}: ActionButtonProps) => {
  const variantClasses = {
    primary: "bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500",
    secondary: "bg-gray-600 text-white hover:bg-gray-700 focus:ring-gray-500",
    outline: "border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 focus:ring-blue-500",
    ghost: "text-gray-700 hover:bg-gray-100 focus:ring-gray-500",
    danger: "bg-red-600 text-white hover:bg-red-700 focus:ring-red-500"
  };

  const sizeClasses = {
    sm: "h-8 px-3 text-sm",
    md: "h-10 px-4 text-sm",
    lg: "h-12 px-6 text-base"
  };

  return (
    <Button
      className={cn(
        "inline-flex items-center justify-center rounded-md font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed",
        variantClasses[variant],
        sizeClasses[size]
      )}
      disabled={disabled || loading}
      onClick={onClick}
    >
      {loading && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
      {Icon && !loading && <Icon className="h-4 w-4 mr-2" />}
      {label}
    </Button>
  );
};
```

## Order Management Screen Layout

### 1. Dashboard Overview
```tsx
const OrderManagementDashboard = () => {
  return (
    <div className="space-y-6">
      {/* Priority Alerts */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <AlertCard
          type="urgent"
          title="Orders Pending Shipment"
          count={5}
          trend="+2 from yesterday"
          color="amber"
          icon={Truck}
        />
        <AlertCard
          type="warning"
          title="Low Stock Items"
          count={12}
          trend="+3 from yesterday"
          color="orange"
          icon={AlertTriangle}
        />
        <AlertCard
          type="info"
          title="Returns to Process"
          count={3}
          trend="Same as yesterday"
          color="blue"
          icon={RotateCcw}
        />
      </div>

      {/* Quick Actions */}
      <div className="flex items-center gap-4">
        <Button className="bg-blue-600 hover:bg-blue-700">
          <Truck className="h-4 w-4 mr-2" />
          Process Shipments
        </Button>
        <Button variant="outline">
          <PackageOpen className="h-4 w-4 mr-2" />
          Update Inventory
        </Button>
        <Button variant="outline">
          <MessageSquare className="h-4 w-4 mr-2" />
          Customer Notifications
        </Button>
      </div>

      {/* Recent Orders Table */}
      <DataTable
        data={recentOrders}
        columns={orderColumns}
        searchable
        filterable
        pagination
        selectable
        bulkActions={[
          { label: 'Mark as Shipped', action: bulkMarkAsShipped },
          { label: 'Send Email', action: bulkSendEmail },
          { label: 'Export', action: bulkExport }
        ]}
      />
    </div>
  );
};
```

### 2. Order Details Modal
```tsx
const OrderDetailsModal = ({ order, isOpen, onClose }) => {
  return (
    <Modal isOpen={isOpen} onClose={onClose} title={`Order ${order.id}`} size="lg">
      <div className="space-y-6">
        {/* Order Status */}
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold">Order Status</h3>
            <StatusBadge status={order.status} showIcon />
          </div>
          <div className="flex gap-2">
            <ActionButton variant="outline" icon={Edit} label="Edit" />
            <ActionButton variant="primary" icon={Package} label="Process" />
          </div>
        </div>

        {/* Customer Information */}
        <div className="grid grid-cols-2 gap-6">
          <div>
            <h4 className="font-medium mb-2">Customer Information</h4>
            <div className="space-y-1 text-sm">
              <p>{order.customer.name}</p>
              <p>{order.customer.email}</p>
              <p>{order.customer.phone}</p>
            </div>
          </div>
          <div>
            <h4 className="font-medium mb-2">Shipping Address</h4>
            <div className="space-y-1 text-sm">
              <p>{order.shipping.address}</p>
              <p>{order.shipping.city}, {order.shipping.state}</p>
              <p>{order.shipping.postalCode}</p>
            </div>
          </div>
        </div>

        {/* Order Items */}
        <div>
          <h4 className="font-medium mb-2">Order Items</h4>
          <Table>
            <TableBody>
              {order.items.map((item) => (
                <TableRow key={item.id}>
                  <TableCell>{item.name}</TableCell>
                  <TableCell>{item.quantity}</TableCell>
                  <TableCell>{formatCurrency(item.price)}</TableCell>
                  <TableCell>{formatCurrency(item.total)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </div>
    </Modal>
  );
};
```

## Responsive Design

### Breakpoints
```css
/* Mobile First Approach */
@media (min-width: 640px) { /* sm */ }
@media (min-width: 768px) { /* md */ }
@media (min-width: 1024px) { /* lg */ }
@media (min-width: 1280px) { /* xl */ }
@media (min-width: 1536px) { /* 2xl */ }
```

### Mobile Adaptations
- Collapsible sidebar with hamburger menu
- Stacked cards instead of grid layout
- Touch-friendly button sizes (minimum 44px)
- Simplified table views with horizontal scrolling
- Bottom navigation for key actions

## Accessibility Features

- **Keyboard Navigation**: Full keyboard accessibility with tab order
- **Screen Reader Support**: Proper ARIA labels and descriptions
- **High Contrast Mode**: Support for high contrast themes
- **Reduced Motion**: Respect user's motion preferences
- **Focus Management**: Clear focus indicators and logical tab order

This design specification provides a comprehensive foundation for building an efficient, accessible, and visually comfortable staff admin panel optimized for extended use.
