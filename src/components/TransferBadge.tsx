export function TransferBadge({ transferable }: { transferable: boolean }) {
  return transferable ? (
    <span className="badge badge-ok">Transferable</span>
  ) : (
    <span className="badge badge-no">Not transferable</span>
  );
}
