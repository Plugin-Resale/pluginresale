// transferable: true = resale allowed, false = not allowed, null = policy not verified yet.
export function TransferBadge({ transferable }: { transferable: boolean | null }) {
  if (transferable === null) return <span className="badge badge-warn">Policy not verified</span>;
  return transferable ? (
    <span className="badge badge-ok">Transferable</span>
  ) : (
    <span className="badge badge-no">Not transferable</span>
  );
}
