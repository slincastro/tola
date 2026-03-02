export interface Surface {
  value: number;
  unit: "m2";
}

export interface Price {
  amount: number;
  currency: "USD";
  negotiable: boolean;
}

export interface Sector {
  name: string;
  city: string;
  province: string;
  country: string;
}

export interface PolygonGeometry {
  type: "Polygon";
  coordinates: number[][][];
}

export interface PointGeometry {
  type: "Point";
  coordinates: number[];
}

export interface Product {
  id: string;
  mid: string;
  name: string;
  description: string;
  surface: Surface;
  services: string[];
  price: Price;
  sector: Sector;
  location: {
    geometry: PolygonGeometry;
    centroid: PointGeometry;
  };
  media: {
    photos: string[];
  };
  createdAt: string;
  updatedAt: string;
}

export interface CreateProductPayload {
  mid: string;
  name: string;
  description: string;
  surface: Surface;
  services: string[];
  price: Price;
  sector: Sector;
  location: {
    geometry: PolygonGeometry;
    centroid: PointGeometry;
  };
  media: {
    photos: string[];
  };
}

export interface ProductPage {
  limit: number;
  nextCursor: string | null;
}

export interface ProductListResponse {
  items: Product[];
  page: ProductPage;
}

export interface ProductFilters {
  limit?: number;
  cursor?: string;
  sector?: string;
  min_price?: number;
  max_price?: number;
  negotiable?: boolean;
  near_lng?: number;
  near_lat?: number;
  radius_meters?: number;
}

export interface ApiClient {
  getProducts: (filters?: ProductFilters) => Promise<ProductListResponse>;
  createProduct: (payload: CreateProductPayload) => Promise<{ id: string; createdAt: string; updatedAt: string }>;
}
