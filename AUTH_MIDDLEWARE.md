# Authentication & Authorization Middleware

## JWT Authentication Implementation

### 1. JWT Configuration

```typescript
// src/config/jwt.ts
export const jwtConfig = {
  secret: process.env.JWT_SECRET || 'your-super-secret-key',
  expiresIn: process.env.JWT_EXPIRES_IN || '24h',
  refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  issuer: 'staff-admin-panel',
  audience: 'staff-users'
};

// JWT Token Interfaces
export interface JWTPayload {
  sub: string; // User ID
  email: string;
  role: 'support_staff' | 'manager';
  permissions: string[];
  iat: number;
  exp: number;
  iss: string;
  aud: string;
}

export interface RefreshTokenPayload {
  sub: string;
  type: 'refresh';
  iat: number;
  exp: number;
}
```

### 2. Authentication Middleware

```typescript
// src/middleware/auth.ts
import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';
import { jwtConfig, JWTPayload } from '../config/jwt';

// Extend Request interface to include user
declare global {
  namespace Express {
    interface Request {
      user?: JWTPayload;
    }
  }
}

export const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Access token is required'
        }
      });
    }

    jwt.verify(token, jwtConfig.secret, (err, decoded) => {
      if (err) {
        return res.status(401).json({
          success: false,
          error: {
            code: 'UNAUTHORIZED',
            message: 'Invalid or expired token'
          }
        });
      }

      req.user = decoded as JWTPayload;
      next();
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Authentication error'
      }
    });
  }
};

export const optionalAuth = (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
      jwt.verify(token, jwtConfig.secret, (err, decoded) => {
        if (!err) {
          req.user = decoded as JWTPayload;
        }
      });
    }

    next();
  } catch (error) {
    next();
  }
};
```

### 3. Role-Based Access Control (RBAC)

```typescript
// src/middleware/permissions.ts
import { Request, Response, NextFunction } from 'express';
import { Permission, Resource, Action } from '../types/auth';

// Permission definitions
export enum Resource {
  PRODUCTS = 'products',
  ORDERS = 'orders',
  CUSTOMERS = 'customers',
  INVENTORY = 'inventory',
  STAFF = 'staff',
  ANALYTICS = 'analytics',
  MARKETING = 'marketing',
  SYSTEM = 'system'
}

export enum Action {
  READ = 'read',
  CREATE = 'create',
  UPDATE = 'update',
  DELETE = 'delete',
  MANAGE = 'manage'
}

// Role-based permission matrix
export const ROLE_PERMISSIONS = {
  support_staff: {
    [Resource.PRODUCTS]: [Action.READ],
    [Resource.ORDERS]: [Action.READ, Action.UPDATE],
    [Resource.CUSTOMERS]: [Action.READ],
    [Resource.INVENTORY]: [Action.READ, Action.UPDATE],
    [Resource.ANALYTICS]: [Action.READ],
    [Resource.MARKETING]: [],
    [Resource.STAFF]: [],
    [Resource.SYSTEM]: []
  },
  manager: {
    [Resource.PRODUCTS]: [Action.READ, Action.CREATE, Action.UPDATE, Action.DELETE],
    [Resource.ORDERS]: [Action.READ, Action.CREATE, Action.UPDATE, Action.DELETE],
    [Resource.CUSTOMERS]: [Action.READ, Action.CREATE, Action.UPDATE, Action.DELETE],
    [Resource.INVENTORY]: [Action.READ, Action.CREATE, Action.UPDATE, Action.DELETE],
    [Resource.STAFF]: [Action.READ, Action.CREATE, Action.UPDATE],
    [Resource.ANALYTICS]: [Action.READ, Action.CREATE],
    [Resource.MARKETING]: [Action.READ, Action.CREATE, Action.UPDATE],
    [Resource.SYSTEM]: [Action.READ]
  }
};

// Permission checking middleware
export const requirePermission = (resource: Resource, action: Action) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required'
        }
      });
    }

    const userRole = req.user.role;
    const userPermissions = ROLE_PERMISSIONS[userRole];
    
    if (!userPermissions || !userPermissions[resource]) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'Insufficient permissions'
        }
      });
    }

    const allowedActions = userPermissions[resource];
    
    if (!allowedActions.includes(action)) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: `Action '${action}' not allowed for resource '${resource}'`
        }
      });
    }

    // Special check for system-level operations
    if (resource === Resource.SYSTEM && userRole !== 'manager') {
      return res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'System operations require manager role'
        }
      });
    }

    next();
  };
};

// Multiple permissions check
export const requireAnyPermission = (permissions: Array<{ resource: Resource; action: Action }>) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required'
        }
      });
    }

    const userRole = req.user.role;
    const userPermissions = ROLE_PERMISSIONS[userRole];

    const hasPermission = permissions.some(({ resource, action }) => {
      const allowedActions = userPermissions[resource];
      return allowedActions && allowedActions.includes(action);
    });

    if (!hasPermission) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'Insufficient permissions for any of the required actions'
        }
      });
    }

    next();
  };
};

// Custom permission check for complex scenarios
export const requireCustomPermission = (checkFn: (user: JWTPayload) => boolean) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required'
        }
      });
    }

    if (!checkFn(req.user)) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'Custom permission check failed'
        }
      });
    }

    next();
  };
};
```

### 4. Authentication Service

```typescript
// src/services/authService.ts
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import { jwtConfig, JWTPayload, RefreshTokenPayload } from '../config/jwt';
import { User } from '../models/User';

export class AuthService {
  // Generate JWT tokens
  static generateTokens(user: User) {
    const payload: JWTPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      permissions: this.getUserPermissions(user.role),
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60), // 24 hours
      iss: jwtConfig.issuer,
      aud: jwtConfig.audience
    };

    const accessToken = jwt.sign(payload, jwtConfig.secret, {
      expiresIn: jwtConfig.expiresIn,
      issuer: jwtConfig.issuer,
      audience: jwtConfig.audience
    });

    const refreshPayload: RefreshTokenPayload = {
      sub: user.id,
      type: 'refresh',
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(Date.now() / 1000) + (7 * 24 * 60 * 60) // 7 days
    };

    const refreshToken = jwt.sign(refreshPayload, jwtConfig.secret, {
      expiresIn: jwtConfig.refreshExpiresIn
    });

    return { accessToken, refreshToken };
  }

  // Verify access token
  static verifyAccessToken(token: string): JWTPayload | null {
    try {
      const decoded = jwt.verify(token, jwtConfig.secret, {
        issuer: jwtConfig.issuer,
        audience: jwtConfig.audience
      }) as JWTPayload;

      return decoded;
    } catch (error) {
      return null;
    }
  }

  // Verify refresh token
  static verifyRefreshToken(token: string): RefreshTokenPayload | null {
    try {
      const decoded = jwt.verify(token, jwtConfig.secret) as RefreshTokenPayload;
      
      if (decoded.type !== 'refresh') {
        return null;
      }

      return decoded;
    } catch (error) {
      return null;
    }
  }

  // Hash password
  static async hashPassword(password: string): Promise<string> {
    const saltRounds = 12;
    return bcrypt.hash(password, saltRounds);
  }

  // Verify password
  static async verifyPassword(password: string, hashedPassword: string): Promise<boolean> {
    return bcrypt.compare(password, hashedPassword);
  }

  // Get user permissions based on role
  static getUserPermissions(role: 'support_staff' | 'manager'): string[] {
    const permissions = ROLE_PERMISSIONS[role];
    const flatPermissions: string[] = [];

    Object.entries(permissions).forEach(([resource, actions]) => {
      actions.forEach(action => {
        flatPermissions.push(`${resource}:${action}`);
      });
    });

    return flatPermissions;
  }

  // Check if user has specific permission
  static hasPermission(user: JWTPayload, resource: Resource, action: Action): boolean {
    const userPermissions = ROLE_PERMISSIONS[user.role];
    return userPermissions[resource]?.includes(action) || false;
  }
}
```

### 5. Authentication Controller

```typescript
// src/controllers/authController.ts
import { Request, Response } from 'express';
import { AuthService } from '../services/authService';
import { User } from '../models/User';

export class AuthController {
  // Login endpoint
  static async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;

      // Validate input
      if (!email || !password) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Email and password are required'
          }
        });
      }

      // Find user
      const user = await User.findOne({ 
        where: { email, isActive: true },
        include: ['permissions']
      });

      if (!user) {
        return res.status(401).json({
          success: false,
          error: {
            code: 'INVALID_CREDENTIALS',
            message: 'Invalid email or password'
          }
        });
      }

      // Verify password
      const isValidPassword = await AuthService.verifyPassword(password, user.password);
      
      if (!isValidPassword) {
        return res.status(401).json({
          success: false,
          error: {
            code: 'INVALID_CREDENTIALS',
            message: 'Invalid email or password'
          }
        });
      }

      // Generate tokens
      const { accessToken, refreshToken } = AuthService.generateTokens(user);

      // Update last login
      await User.update(
        { lastLoginAt: new Date() },
        { where: { id: user.id } }
      );

      // Return user data and tokens
      res.json({
        success: true,
        data: {
          token: accessToken,
          refreshToken,
          user: {
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role,
            permissions: AuthService.getUserPermissions(user.role),
            lastLoginAt: user.lastLoginAt
          }
        }
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Login failed'
        }
      });
    }
  }

  // Refresh token endpoint
  static async refreshToken(req: Request, res: Response) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Refresh token is required'
          }
        });
      }

      // Verify refresh token
      const decoded = AuthService.verifyRefreshToken(refreshToken);
      
      if (!decoded) {
        return res.status(401).json({
          success: false,
          error: {
            code: 'INVALID_TOKEN',
            message: 'Invalid or expired refresh token'
          }
        });
      }

      // Find user
      const user = await User.findByPk(decoded.sub, {
        include: ['permissions']
      });

      if (!user || !user.isActive) {
        return res.status(401).json({
          success: false,
          error: {
            code: 'USER_NOT_FOUND',
            message: 'User not found or inactive'
          }
        });
      }

      // Generate new tokens
      const { accessToken, refreshToken: newRefreshToken } = AuthService.generateTokens(user);

      res.json({
        success: true,
        data: {
          token: accessToken,
          refreshToken: newRefreshToken
        }
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Token refresh failed'
        }
      });
    }
  }

  // Logout endpoint
  static async logout(req: Request, res: Response) {
    try {
      // In a real implementation, you would add the token to a blacklist
      // For now, we'll just return success
      res.json({
        success: true,
        message: 'Logged out successfully'
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Logout failed'
        }
      });
    }
  }

  // Get current user info
  static async getCurrentUser(req: Request, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: {
            code: 'UNAUTHORIZED',
            message: 'Authentication required'
          }
        });
      }

      const user = await User.findByPk(req.user.sub, {
        attributes: { exclude: ['password'] },
        include: ['permissions']
      });

      if (!user) {
        return res.status(404).json({
          success: false,
          error: {
            code: 'USER_NOT_FOUND',
            message: 'User not found'
          }
        });
      }

      res.json({
        success: true,
        data: {
          user: {
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role,
            permissions: AuthService.getUserPermissions(user.role),
            createdAt: user.createdAt,
            lastLoginAt: user.lastLoginAt
          }
        }
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to get user info'
        }
      });
    }
  }
}
```

### 6. Route Protection Examples

```typescript
// src/routes/auth.ts
import { Router } from 'express';
import { AuthController } from '../controllers/authController';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Public routes
router.post('/login', AuthController.login);
router.post('/refresh', AuthController.refreshToken);

// Protected routes
router.post('/logout', authenticateToken, AuthController.logout);
router.get('/me', authenticateToken, AuthController.getCurrentUser);

export default router;
```

```typescript
// src/routes/inventory.ts
import { Router } from 'express';
import { InventoryController } from '../controllers/inventoryController';
import { authenticateToken, requirePermission } from '../middleware/auth';
import { Resource, Action } from '../types/auth';

const router = Router();

// All inventory routes require authentication
router.use(authenticateToken);

// GET /api/inventory/products - Read access for all staff
router.get('/products', 
  requirePermission(Resource.PRODUCTS, Action.READ), 
  InventoryController.getProducts
);

// POST /api/inventory/products - Create access for managers only
router.post('/products', 
  requirePermission(Resource.PRODUCTS, Action.CREATE), 
  InventoryController.createProduct
);

// PUT /api/inventory/products/:id - Update access for managers only
router.put('/products/:id', 
  requirePermission(Resource.PRODUCTS, Action.UPDATE), 
  InventoryController.updateProduct
);

// DELETE /api/inventory/products/:id - Delete access for managers only
router.delete('/products/:id', 
  requirePermission(Resource.PRODUCTS, Action.DELETE), 
  InventoryController.deleteProduct
);

// Stock adjustment - Update access for all staff
router.post('/stock-adjustment', 
  requirePermission(Resource.INVENTORY, Action.UPDATE), 
  InventoryController.adjustStock
);

export default router;
```

### 7. Frontend Authentication Hook

```typescript
// frontend/src/hooks/useAuth.ts
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { authService } from '../services/auth';

interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: 'support_staff' | 'manager';
  permissions: string[];
}

export const useAuth = () => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const initAuth = async () => {
      const token = localStorage.getItem('accessToken');
      
      if (token) {
        try {
          const userData = await authService.getCurrentUser();
          setUser(userData.user);
        } catch (error) {
          // Token invalid, clear storage
          localStorage.removeItem('accessToken');
          localStorage.removeItem('refreshToken');
        }
      }
      
      setLoading(false);
    };

    initAuth();
  }, []);

  const login = async (email: string, password: string) => {
    try {
      const response = await authService.login(email, password);
      const { token, refreshToken, user: userData } = response.data;
      
      localStorage.setItem('accessToken', token);
      localStorage.setItem('refreshToken', refreshToken);
      setUser(userData);
      
      return response;
    } catch (error) {
      throw error;
    }
  };

  const logout = () => {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    setUser(null);
    navigate('/login');
  };

  const hasPermission = (resource: string, action: string): boolean => {
    if (!user) return false;
    return user.permissions.includes(`${resource}:${action}`);
  };

  const isManager = (): boolean => {
    return user?.role === 'manager';
  };

  return {
    user,
    loading,
    login,
    logout,
    hasPermission,
    isManager,
    isAuthenticated: !!user
  };
};
```

This comprehensive authentication and authorization system provides:

1. **Secure JWT-based authentication** with access and refresh tokens
2. **Role-based access control** with granular permissions
3. **Middleware for route protection** and permission checking
4. **Password hashing and verification** using bcrypt
5. **Frontend authentication hooks** for easy integration
6. **Token refresh mechanism** for extended sessions
7. **Comprehensive error handling** and security best practices

The system is designed to be secure, scalable, and easy to maintain while providing fine-grained control over user access to different resources and actions.
