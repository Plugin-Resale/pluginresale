export type Review = {
  id: number;
  deal_id: number;
  author_id: string;
  target_id: string;
  rating: number;
  comment: string;
  created_at: string;
};

export type SellerStats = {
  seller_id: string;
  completed_sales: number;
  avg_rating: number | null;
  review_count: number;
};
