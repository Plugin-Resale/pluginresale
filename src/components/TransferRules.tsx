import { formatDate, type Developer } from "@/lib/catalog";
import { TransferBadge } from "./TransferBadge";

// The developer's license-transfer rules box (developer page, listing page, sell form).
export function TransferRules({ developer }: { developer: Developer }) {
  const rows: [string, string | null][] = developer.transferable
    ? [
        ["Developer transfer fee", developer.fee],
        ["Who pays the fee", developer.who_pays],
        ["How it works", developer.process],
        ["Typical delay", developer.typical_delay],
        ["Restrictions", developer.restrictions],
      ]
    : [
        ["Why", developer.restrictions],
        ["Details", developer.process],
      ];

  const subject = encodeURIComponent(`Outdated transfer rules: ${developer.name}`);

  return (
    <section className="rules card">
      <div className="rules-head">
        <h2>{developer.name} transfer rules</h2>
        <TransferBadge transferable={developer.transferable} />
      </div>
      <dl>
        {rows
          .filter(([, value]) => value)
          .map(([label, value]) => (
            <div className="rules-row" key={label}>
              <dt>{label}</dt>
              <dd>{value}</dd>
            </div>
          ))}
        <div className="rules-row">
          <dt>Last verified</dt>
          <dd>
            {developer.last_verified ? formatDate(developer.last_verified) : "Not verified yet"}
            {developer.source_url && (
              <>
                {" · "}
                <a href={developer.source_url} target="_blank" rel="noopener noreferrer">
                  Official source
                </a>
              </>
            )}
          </dd>
        </div>
      </dl>
      <p className="rules-foot">
        For information only, provided as is: policies change without notice. Always check
        the transfer conditions with the developer before paying.{" "}
        <a href={`mailto:contact@pluginresale.com?subject=${subject}`}>Report outdated info</a>
      </p>
    </section>
  );
}
