export type DealStatus = "requested" | "paid" | "completed" | "cancelled";

export type Deal = {
  id: number;
  listing_id: number;
  buyer_id: string;
  seller_id: string;
  price_eur: number;
  status: DealStatus;
  created_at: string;
  paid_at: string | null;
  completed_at: string | null;
  cancelled_at: string | null;
  cancelled_by: string | null;
};

export const DEAL_STATUS_LABELS: Record<DealStatus, string> = {
  requested: "Waiting for payment",
  paid: "Transferring license",
  completed: "Completed",
  cancelled: "Cancelled",
};
