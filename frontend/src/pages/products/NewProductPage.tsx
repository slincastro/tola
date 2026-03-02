import { ProductForm } from "@/components/products/ProductForm";

type Props = {
  onCreated: (message: string) => void;
};

export function NewProductPage({ onCreated }: Props) {
  return <ProductForm onCreated={onCreated} />;
}
