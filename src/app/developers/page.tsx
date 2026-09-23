import type { Metadata } from "next";
import Link from "next/link";
import { TransferBadge } from "@/components/TransferBadge";
import { DEVELOPER_COLUMNS, type Developer } from "@/lib/catalog";
import { createClient } from "@/lib/supabase/server";

export const metadata: Metadata = {
  title: "Developer transfer rules",
  description:
    "License transfer policies of audio plugin developers: fees, who pays, process and restrictions.",
};

export default async function DevelopersPage() {
  const supabase = await createClient();
  const { data: developers, error } = await supabase
    .from("developers")
    .select(DEVELOPER_COLUMNS)
    .order("name")
    .returns<Developer[]>();

  if (error) throw error;

  return (
    <main className="container page">
      <p className="eyebrow">Transfer rules database</p>
      <h1 className="page-title">Know the transfer rules before you buy</h1>
      <p className="lead">
        Every developer handles second-hand licenses differently. Check the fee, who pays and how
        the transfer works before you list or buy.
      </p>

      <ul className="dev-grid">
        {developers.map((dev) => (
          <li key={dev.id}>
            <Link href={`/developers/${dev.slug}`} className="dev-card">
              <span className="dev-card-name">{dev.name}</span>
              <TransferBadge transferable={dev.transferable} />
              <span className="dev-card-fee">
                {dev.transferable ? (dev.fee ?? "Fee not stated") : "Licenses can't be resold"}
              </span>
              <span className="dev-card-link">Transfer rules →</span>
            </Link>
          </li>
        ))}
      </ul>
    </main>
  );
}
