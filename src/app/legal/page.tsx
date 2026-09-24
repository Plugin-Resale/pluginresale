import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Legal notice",
  description: "Who publishes Plugin Resale and who hosts it.",
};

const EMAIL = <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a>;
const PHONE = <a href="tel:+33664535014">+33 6 64 53 50 14</a>;
const CM2C = (
  <a href="https://www.cm2c.net" target="_blank" rel="noopener noreferrer">
    www.cm2c.net
  </a>
);
const VERCEL = "Vercel Inc., 440 N Barranca Avenue #4133, Covina, CA 91723, United States — vercel.com";
const SUPABASE =
  "Supabase Pte. Ltd., 65 Chulia Street #38-02/03, OCBC Centre, Singapore 049513 — supabase.com";

// French LCEN (art. 6 and 19): identity of the publisher, publication director and host.
// Code de la consommation (L616-1): the consumer mediator.
export default function LegalPage() {
  return (
    <main className="narrow narrow-wide page legal">
      <h1 className="page-title" id="en">
        Legal notice
      </h1>
      <p className="lang-switch">
        <a href="#fr" lang="fr">
          Mentions légales en français ↓
        </a>
      </p>

      <h2>Publisher</h2>
      <p>
        pluginresale.com is published by <strong>SAS Boring Vic</strong>, a French{" "}
        <em>société par actions simplifiée</em> with a share capital of €300.
      </p>
      <ul>
        <li>Registered office: 5 rue Henry Le Chatelier, 38000 Grenoble, France</li>
        <li>Registration: 978 440 972 R.C.S. Grenoble</li>
        <li>VAT number: FR11978440972</li>
        <li>Email: {EMAIL}</li>
        <li>Phone: {PHONE}</li>
        <li>Publication director: Victor Malvolti, President</li>
      </ul>

      <h2>Hosting</h2>
      <ul>
        <li>Website: {VERCEL}</li>
        <li>Database and accounts (data stored in Ireland, EU): {SUPABASE}</li>
      </ul>

      <h2>Point of contact (EU Digital Services Act)</h2>
      <p>
        Authorities and users can reach us at {EMAIL}, in English or French. To report a listing,
        a user or any content, use the <Link href="/report">report form</Link>.
      </p>

      <h2>Consumer mediation</h2>
      <p>
        CM2C — Centre de la Médiation de la Consommation de Conciliateurs de Justice, 49 rue de
        Ponthieu, 75008 Paris, France — {CM2C}. See section 19 of our{" "}
        <Link href="/terms">Terms of Service</Link>.
      </p>

      <h2>Intellectual property</h2>
      <p>
        Plugin and developer names are trademarks of their respective owners. They are used only
        to identify the licenses offered for sale. Plugin Resale isn&apos;t affiliated with or
        endorsed by any plugin developer.
      </p>

      {/* ---------------------------------------------------------------- French version */}

      <section id="fr" lang="fr" className="legal-fr">
        <h1 className="page-title">Mentions légales</h1>
        <p className="lang-switch">
          <a href="#en" lang="en">
            English version ↑
          </a>
        </p>

        <h2>Éditeur</h2>
        <p>
          Le site pluginresale.com est édité par <strong>SAS Boring Vic</strong>, société par
          actions simplifiée au capital de 300 €.
        </p>
        <ul>
          <li>Siège social : 5 rue Henry Le Chatelier, 38000 Grenoble, France</li>
          <li>Immatriculation : 978 440 972 R.C.S. Grenoble</li>
          <li>Numéro de TVA intracommunautaire : FR11978440972</li>
          <li>Email : {EMAIL}</li>
          <li>Téléphone : {PHONE}</li>
          <li>Directeur de la publication : Victor Malvolti, Président</li>
        </ul>

        <h2>Hébergement</h2>
        <ul>
          <li>Site : {VERCEL}</li>
          <li>
            Base de données et comptes (données stockées en Irlande, UE) : {SUPABASE}
          </li>
        </ul>

        <h2>Point de contact (règlement européen sur les services numériques)</h2>
        <p>
          Les autorités et les utilisateurs peuvent nous joindre à {EMAIL}, en français ou en
          anglais. Pour signaler une annonce, un utilisateur ou tout contenu, utilisez le{" "}
          <Link href="/report">formulaire de signalement</Link>.
        </p>

        <h2>Médiation de la consommation</h2>
        <p>
          CM2C — Centre de la Médiation de la Consommation de Conciliateurs de Justice, 49 rue de
          Ponthieu, 75008 Paris — {CM2C}. Voir l&apos;article 19 de nos{" "}
          <Link href="/terms#fr">conditions générales d&apos;utilisation</Link>.
        </p>

        <h2>Propriété intellectuelle</h2>
        <p>
          Les noms des plugins et des éditeurs sont des marques appartenant à leurs titulaires
          respectifs. Ils sont utilisés uniquement pour identifier les licences mises en vente.
          Plugin Resale n&apos;est affilié à aucun éditeur de plugins et n&apos;est approuvé par
          aucun d&apos;eux.
        </p>
      </section>
    </main>
  );
}
