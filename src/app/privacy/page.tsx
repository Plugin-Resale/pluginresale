import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description: "What data Plugin Resale collects and why, and your rights over it.",
};

export default function PrivacyPage() {
  return (
    <main className="narrow narrow-wide page legal">
      <h1 className="page-title" id="en">
        Privacy Policy
      </h1>
      <p className="lead">Last updated 24 September 2026.</p>
      <p className="lang-switch">
        <a href="#fr" lang="fr">
          Version française ↓
        </a>
      </p>

      <p>
        This policy explains what personal data Plugin Resale (pluginresale.com) collects, why,
        and what you can do about it. The data controller is SAS Boring Vic, 5 rue Henry Le
        Chatelier, 38000 Grenoble, France — 978 440 972 R.C.S. Grenoble (see our{" "}
        <Link href="/legal">legal notice</Link>). Contact us about privacy at{" "}
        <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a>.
      </p>

      <h2>1. Data we collect</h2>
      <ul>
        <li>
          <strong>Account:</strong> your email address (to sign you in with a magic link), the
          username you choose, and the date you accepted our Terms.
        </li>
        <li>
          <strong>Listings:</strong> the plugin, version, price, description and the PayPal email
          you enter when selling.
        </li>
        <li>
          <strong>Deals, messages and reviews:</strong> records of purchases (status, dates,
          price), the messages you exchange with other users, and reviews you write or receive.
        </li>
        <li>
          <strong>Reports:</strong> if you report content, your email and what you tell us.
        </li>
        <li>
          <strong>Technical data:</strong> server and sign-in logs (IP address, browser, time)
          kept by our providers for security.
        </li>
      </ul>
      <p>
        Your email is required to create an account; everything else is data you choose to
        post. We don&apos;t use analytics or advertising cookies, and we don&apos;t make
        automated decisions about you.
      </p>

      <h2>2. Why we use it, and on what legal basis</h2>
      <ul>
        <li>
          <strong>Running the marketplace</strong> — your account, listings, purchases,
          messages and the emails a deal or message needs: to perform our contract with you
          (GDPR art. 6(1)(b)).
        </li>
        <li>
          <strong>Trust and safety</strong> — public ratings and reviews, handling reports,
          preventing fraud and abuse, security logs: our legitimate interest in running a
          trustworthy marketplace (art. 6(1)(f)).
        </li>
        <li>
          <strong>Legal obligations</strong> — keeping the identification data French law
          requires hosting providers to keep, answering lawful requests from authorities
          (art. 6(1)(c)).
        </li>
      </ul>
      <p>We don&apos;t sell your data, and we don&apos;t send you marketing emails.</p>

      <h2>3. Who can see it</h2>
      <ul>
        <li>
          <strong>Everyone:</strong> your username, your listings (without your PayPal email),
          the reviews you write and receive, your rating, and the date you joined.
        </li>
        <li>
          <strong>The other side of a deal:</strong> the buyer of an active purchase sees the
          seller&apos;s PayPal email; buyer and seller see each other&apos;s username and their
          messages.
        </li>
        <li>
          <strong>Us:</strong> we can access data when needed to run the site, handle a report or
          prevent fraud.
        </li>
        <li>
          <strong>Our service providers</strong>, only as needed to run the site: Supabase
          (database, sign-in and data hosting), Vercel (website hosting), Resend (sign-in and
          notification emails), GitHub (storage of our encrypted database backups, which it
          can&apos;t read) and Google (Gmail, which receives the emails sent to
          contact@pluginresale.com).
        </li>
        <li>
          <strong>Authorities</strong>, when the law requires it.
        </li>
      </ul>
      <p>
        PayPal is not one of our providers. Payment happens directly between you and the other
        user on PayPal&apos;s own platform; we don&apos;t send PayPal any data.
      </p>

      <h2>4. International transfers</h2>
      <p>
        Our database, which holds your account data, is hosted in the EU (Ireland). Vercel,
        Resend, GitHub and Google are based in the United States and Supabase in Singapore, so
        some data may be processed outside the EU. Vercel, Resend, GitHub and Google are
        certified under the EU-U.S. Data Privacy Framework, and our providers&apos; data
        processing agreements include the European Commission&apos;s Standard Contractual
        Clauses.
      </p>

      <h2>5. Cookies</h2>
      <p>
        We use one strictly necessary cookie to keep you signed in. It&apos;s required for the
        site to work and doesn&apos;t need your consent under EU law. Our fonts are served from
        our own site, not from a third party. If we ever add advertising or analytics that use
        non-essential cookies, we&apos;ll ask for your consent first and update this page.
      </p>

      <h2>6. How long we keep it</h2>
      <ul>
        <li>
          <strong>Account data:</strong> as long as your account exists. Accounts inactive for
          3 years are deleted, after an email warning.
        </li>
        <li>
          <strong>Deals, messages and reviews:</strong> 5 years after the deal or the
          conversation ends (the time limit for legal claims), then deleted.
        </li>
        <li>
          <strong>Reports:</strong> up to 1 year after we&apos;ve handled them.
        </li>
        <li>
          <strong>Logs:</strong> for the short periods set by our providers.
        </li>
        <li>
          <strong>Backups:</strong> an encrypted copy of the database is made every day and
          each copy is deleted after 30 days, so deleted data fully disappears within 30 days.
        </li>
      </ul>
      <p>
        <strong>When you delete your account</strong> (from My account), your listings go
        offline, your email and PayPal emails are erased from the site, and your username is
        replaced by an anonymous one. Past deals and reviews stay attached to that anonymous
        profile so the other side&apos;s history still makes sense. As French law requires of
        hosting providers, we keep your email and former username in a separate, restricted
        archive for 1 year, used only to answer requests from judicial authorities, and then
        delete it.
      </p>

      <h2>7. Your rights</h2>
      <p>Under the GDPR, you can:</p>
      <ul>
        <li>Access the personal data we hold about you, and get a copy in a portable format.</li>
        <li>Correct it if it&apos;s inaccurate.</li>
        <li>Delete it — you can delete your account yourself from My account.</li>
        <li>Object to, or ask us to restrict, how we use it.</li>
        <li>
          Tell us what should happen to your data after your death (French Data Protection Act).
        </li>
      </ul>
      <p>
        Email <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a> to exercise
        any of these. We&apos;ll answer within one month, and may ask you to confirm your
        identity from the email address of your account. You can also complain to your national
        data protection authority — in France, the CNIL (cnil.fr).
      </p>

      <h2>8. Security</h2>
      <p>
        We use access controls in our database so each user only sees what they&apos;re allowed
        to see, encryption in transit (HTTPS) for all traffic, and established providers for
        hosting and email. No system is perfectly secure: if a data breach puts your rights at
        risk, we&apos;ll tell you and the CNIL as the law requires.
      </p>

      <h2>9. Age</h2>
      <p>Plugin Resale is for adults only (18 or older).</p>

      <h2>10. Changes</h2>
      <p>
        We may update this policy as the site evolves. We&apos;ll post the new version here with
        an updated date, and email you about any important change. This policy exists in
        English and in French; if they differ, the French version prevails.
      </p>

      {/* ---------------------------------------------------------------- French version */}

      <section id="fr" lang="fr" className="legal-fr">
        <h1 className="page-title">Politique de confidentialité</h1>
        <p className="lead">Dernière mise à jour : 24 septembre 2026.</p>
        <p className="lang-switch">
          <a href="#en" lang="en">
            English version ↑
          </a>
        </p>

        <p>
          Cette politique explique quelles données personnelles Plugin Resale
          (pluginresale.com) collecte, pourquoi, et quels sont vos droits. Le responsable du
          traitement est SAS Boring Vic, 5 rue Henry Le Chatelier, 38000 Grenoble, France — 978
          440 972 R.C.S. Grenoble (voir nos <Link href="/legal#fr">mentions légales</Link>). Pour
          toute question relative à vos données :{" "}
          <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a>.
        </p>

        <h2>1. Données collectées</h2>
        <ul>
          <li>
            <strong>Compte :</strong> votre adresse email (pour vous connecter par lien), le
            pseudo que vous choisissez et la date à laquelle vous avez accepté nos conditions.
          </li>
          <li>
            <strong>Annonces :</strong> le plugin, la version, le prix, la description et
            l&apos;email PayPal que vous indiquez pour vendre.
          </li>
          <li>
            <strong>Ventes, messages et avis :</strong> l&apos;historique des achats (statut,
            dates, prix), les messages échangés avec d&apos;autres utilisateurs et les avis que
            vous rédigez ou recevez.
          </li>
          <li>
            <strong>Signalements :</strong> si vous signalez un contenu, votre email et ce que
            vous nous indiquez.
          </li>
          <li>
            <strong>Données techniques :</strong> journaux serveur et de connexion (adresse IP,
            navigateur, horodatage) conservés par nos prestataires pour la sécurité.
          </li>
        </ul>
        <p>
          Votre email est nécessaire pour créer un compte ; le reste correspond aux informations
          que vous choisissez de publier. Nous n&apos;utilisons aucun cookie d&apos;analyse ou
          publicitaire et ne prenons aucune décision automatisée vous concernant.
        </p>

        <h2>2. Finalités et bases légales</h2>
        <ul>
          <li>
            <strong>Fonctionnement de la plateforme</strong> — compte, annonces, achats,
            messages et emails nécessaires à une vente ou à un message : exécution du contrat qui
            nous lie (art. 6.1.b du RGPD).
          </li>
          <li>
            <strong>Confiance et sécurité</strong> — notes et avis publics, traitement des
            signalements, prévention de la fraude et des abus, journaux de sécurité : notre
            intérêt légitime à faire fonctionner une plateforme fiable (art. 6.1.f).
          </li>
          <li>
            <strong>Obligations légales</strong> — conservation des données d&apos;identification
            imposée aux hébergeurs par la loi française, réponse aux demandes des autorités
            (art. 6.1.c).
          </li>
        </ul>
        <p>Nous ne vendons pas vos données et ne vous envoyons pas d&apos;emails marketing.</p>

        <h2>3. Qui peut y accéder</h2>
        <ul>
          <li>
            <strong>Tout le monde :</strong> votre pseudo, vos annonces (sans votre email
            PayPal), les avis que vous rédigez et recevez, votre note et votre date
            d&apos;inscription.
          </li>
          <li>
            <strong>L&apos;autre partie d&apos;une vente :</strong> l&apos;acheteur d&apos;un achat
            en cours voit l&apos;email PayPal du vendeur ; l&apos;acheteur et le vendeur voient le
            pseudo de l&apos;autre et leurs messages.
          </li>
          <li>
            <strong>Nous :</strong> nous pouvons accéder aux données lorsque c&apos;est
            nécessaire au fonctionnement du site, au traitement d&apos;un signalement ou à la
            prévention de la fraude.
          </li>
          <li>
            <strong>Nos sous-traitants</strong>, uniquement pour faire fonctionner le site :
            Supabase (base de données, connexion et hébergement des données), Vercel (hébergement
            du site), Resend (emails de connexion et de notification), GitHub (stockage de nos
            sauvegardes chiffrées, qu&apos;il ne peut pas lire) et Google (Gmail, qui reçoit les
            emails envoyés à contact@pluginresale.com).
          </li>
          <li>
            <strong>Les autorités</strong>, lorsque la loi l&apos;exige.
          </li>
        </ul>
        <p>
          PayPal ne fait pas partie de nos sous-traitants. Le paiement se fait directement entre
          vous et l&apos;autre utilisateur sur la plateforme de PayPal ; nous ne transmettons
          aucune donnée à PayPal.
        </p>

        <h2>4. Transferts hors de l&apos;Union européenne</h2>
        <p>
          Notre base de données, qui contient les données de votre compte, est hébergée dans
          l&apos;UE (Irlande). Vercel, Resend, GitHub et Google sont établis aux États-Unis et
          Supabase à Singapour : certaines données peuvent donc être traitées hors de l&apos;UE.
          Vercel, Resend, GitHub et Google sont certifiés au titre du Data Privacy Framework
          UE–États-Unis, et les accords de traitement de nos sous-traitants intègrent les clauses
          contractuelles types de la Commission européenne.
        </p>

        <h2>5. Cookies</h2>
        <p>
          Nous utilisons un seul cookie, strictement nécessaire, pour vous garder connecté. Il est
          indispensable au fonctionnement du site et ne nécessite pas votre consentement en
          droit européen. Nos polices de caractères sont servies depuis notre propre site, et non
          par un tiers. Si nous ajoutons un jour de la publicité ou des statistiques utilisant des
          cookies non essentiels, nous vous demanderons d&apos;abord votre consentement et
          mettrons cette page à jour.
        </p>

        <h2>6. Durées de conservation</h2>
        <ul>
          <li>
            <strong>Données du compte :</strong> tant que votre compte existe. Les comptes
            inactifs depuis 3 ans sont supprimés, après un email d&apos;avertissement.
          </li>
          <li>
            <strong>Ventes, messages et avis :</strong> 5 ans après la fin de la vente ou de la
            conversation (délai de prescription des actions en justice), puis supprimés.
          </li>
          <li>
            <strong>Signalements :</strong> jusqu&apos;à 1 an après leur traitement.
          </li>
          <li>
            <strong>Journaux :</strong> pendant les courtes durées fixées par nos prestataires.
          </li>
          <li>
            <strong>Sauvegardes :</strong> une copie chiffrée de la base est réalisée chaque jour
            et chaque copie est supprimée au bout de 30 jours ; les données effacées
            disparaissent donc totalement sous 30 jours.
          </li>
        </ul>
        <p>
          <strong>Lorsque vous supprimez votre compte</strong> (depuis My account), vos annonces
          sont retirées, votre email et vos emails PayPal sont effacés du site et votre pseudo est
          remplacé par un pseudo anonyme. Les ventes et avis passés restent rattachés à ce profil
          anonyme, afin que l&apos;historique de l&apos;autre partie reste compréhensible. Comme
          la loi française l&apos;impose aux hébergeurs, nous conservons votre email et votre
          ancien pseudo dans une archive séparée et à accès restreint pendant 1 an, uniquement
          pour répondre aux réquisitions judiciaires, puis nous les supprimons.
        </p>

        <h2>7. Vos droits</h2>
        <p>Conformément au RGPD, vous pouvez :</p>
        <ul>
          <li>
            Accéder aux données personnelles que nous détenons sur vous et en obtenir une copie
            dans un format portable.
          </li>
          <li>Les faire rectifier si elles sont inexactes.</li>
          <li>
            Les faire effacer — vous pouvez supprimer vous-même votre compte depuis My account.
          </li>
          <li>Vous opposer à leur utilisation ou en demander la limitation.</li>
          <li>
            Définir des directives relatives au sort de vos données après votre décès (loi
            Informatique et Libertés).
          </li>
        </ul>
        <p>
          Écrivez à <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a> pour
          exercer ces droits. Nous répondons dans un délai d&apos;un mois et pouvons vous demander
          de confirmer votre identité depuis l&apos;adresse email de votre compte. Vous pouvez
          également introduire une réclamation auprès de l&apos;autorité de protection des
          données de votre pays — en France, la CNIL (cnil.fr).
        </p>

        <h2>8. Sécurité</h2>
        <p>
          Nous utilisons des contrôles d&apos;accès dans notre base de données pour que chaque
          utilisateur ne voie que ce qu&apos;il est autorisé à voir, le chiffrement en transit
          (HTTPS) pour tout le trafic, et des prestataires reconnus pour l&apos;hébergement et les
          emails. Aucun système n&apos;est parfaitement sûr : si une violation de données présente
          un risque pour vos droits, nous vous en informerons, ainsi que la CNIL, comme la loi
          l&apos;exige.
        </p>

        <h2>9. Âge</h2>
        <p>Plugin Resale est réservé aux personnes majeures (18 ans ou plus).</p>

        <h2>10. Modifications</h2>
        <p>
          Nous pouvons modifier cette politique pour accompagner l&apos;évolution du site. La
          nouvelle version sera publiée ici avec sa date de mise à jour, et nous vous
          préviendrons par email de toute modification importante. Cette politique existe en
          anglais et en français ; en cas de différence, la version française prévaut.
        </p>
      </section>
    </main>
  );
}
