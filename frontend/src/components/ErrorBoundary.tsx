import { Component, type ErrorInfo, type ReactNode } from "react";

type Props = { children: ReactNode };
type State = { hasError: boolean };

export class ErrorBoundary extends Component<Props, State> {
  public state: State = { hasError: false };

  public static getDerivedStateFromError(): State {
    return { hasError: true };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error("UI ErrorBoundary caught error", error, errorInfo);
  }

  public render() {
    if (this.state.hasError) {
      return (
        <div className="mx-auto mt-10 max-w-xl rounded-2xl border border-red-200 bg-red-50 p-6 text-red-900">
          <h2 className="text-lg font-semibold">Something went wrong</h2>
          <p className="mt-1 text-sm">Please refresh the page.</p>
        </div>
      );
    }

    return this.props.children;
  }
}
