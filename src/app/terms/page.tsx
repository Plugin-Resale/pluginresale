import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Terms of Service",
  description: "The terms that apply when you use Plugin Resale.",
};

const EMAIL = <a href="mailto:contact@pluginresale.com">contact@pluginresale.com</a>;
const CM2C = (
  <a href="https://www.cm2c.net" target="_blank" rel="noopener noreferrer">
    www.cm2c.net
  </a>
);

export default function TermsPage() {
  return (
    <main className="narrow narrow-wide page legal">
      <h1 className="page-title" id="en">
        Terms of Service
      </h1>
      <p className="lead">Last updated 24 September 2026.</p>
      <p className="lang-switch">
        <a href="#fr" lang="fr">
          Version française ↓
        </a>
      </p>

      <p>
        Plugin Resale (pluginresale.com) is operated by SAS Boring Vic (&quot;we&quot;,
        &quot;us&quot;), registered address 5 rue Henry Le Chatelier, 38000 Grenoble, France —
        978 440 972 R.C.S. Grenoble. Full details are in our{" "}
        <Link href="/legal">legal notice</Link>. You can reach us at {EMAIL}. You accept these
        terms when you set up your account, by ticking the box next to them. These terms exist
        in English and in French; both versions have the same value, and if they differ, the
        French version prevails.
      </p>

      <h2>1. What Plugin Resale is</h2>
      <p>
        Plugin Resale is a platform where private individuals list and buy second-hand audio
        plugin licenses from each other. We host the listings and put buyers and sellers in
        touch; each sale is a contract between the buyer and the seller only. It is free to list
        and free to buy, and we take no commission. We may show advertising in the future, but
        we&apos;ll never take a cut of your sales.
      </p>

      <h2>2. Who can use it</h2>
      <ul>
        <li>You must be 18 or older.</li>
        <li>
          Plugin Resale is for private individuals selling licenses they bought for their own
          use. Professional sellers (shops, resellers, developers, anyone selling as part of a
          business) may not list licenses.
        </li>
      </ul>

      <h2>3. Accounts</h2>
      <p>
        You need an account (email + magic link, no password) to sell, buy, message or review.
        Use a real, working email address, keep one account per person, and keep your
        information accurate. You&apos;re responsible for what happens under your account.
      </p>

      <h2>4. Selling</h2>
      <p>Before publishing a listing, you confirm that:</p>
      <ul>
        <li>
          You own the license and it is not a Not-For-Resale, educational, or hardware-bundled
          license.
        </li>
        <li>
          You will uninstall the plugin and complete the developer&apos;s official transfer
          process once you&apos;re paid.
        </li>
        <li>You&apos;re selling as a private individual, not as part of a business.</li>
      </ul>
      <p>
        You&apos;re responsible for the accuracy of your listing and for checking that your
        license can be transferred under its developer&apos;s terms. Listing a license you
        don&apos;t own, or one that its developer doesn&apos;t allow to be transferred, breaks
        these terms.
      </p>

      <h2>5. Buying and payment</h2>
      <p>
        Plugin Resale is never a party to the payment. When you click &quot;Buy with
        PayPal&quot;, the listing is reserved for you and you see the seller&apos;s PayPal email.
        You then pay the seller directly with PayPal <strong>Goods &amp; Services</strong> —
        never &quot;Friends &amp; Family&quot;. We don&apos;t process, hold, or touch the money at
        any point, and we don&apos;t charge a fee on it. Your payment may be covered by PayPal
        Buyer Protection, under PayPal&apos;s own terms, which we don&apos;t control. Either side
        can cancel a purchase until the seller confirms the payment arrived.
      </p>
      <p>
        Before paying, the buyer must check the transfer conditions with the developer (see
        section 7). Because every seller is a private individual, the EU consumer rights that
        apply when buying from a business (such as the 14-day withdrawal right and the legal
        guarantee of conformity) don&apos;t apply to these sales. The general law of contracts
        between individuals still does.
      </p>

      <h2>6. Problems between buyer and seller</h2>
      <p>
        If a payment or a license transfer goes wrong, contact the other user first and, if
        needed, open a case in PayPal&apos;s Resolution Center. We don&apos;t mediate disputes
        between users or issue refunds. We do act on reports of fraud or abuse (see section 13),
        and we cooperate with the authorities when the law requires it.
      </p>

      <h2>7. Developer transfer rules: information only</h2>
      <p>
        The developer transfer rules shown on the site (fees, process, delays, restrictions, the
        &quot;transferable&quot; label and the filters based on it) are a summary we make, free
        of charge, from each developer&apos;s public information. This information is provided{" "}
        <strong>&quot;as is&quot;, for information only</strong>:
      </p>
      <ul>
        <li>
          Developers can change their policies at any time without telling us. We don&apos;t
          guarantee that the information is accurate, complete or up to date, even when a
          &quot;last verified&quot; date is shown.
        </li>
        <li>
          It isn&apos;t legal advice, and it isn&apos;t a statement made by or on behalf of any
          developer. The developer&apos;s own license terms (EULA) and transfer policy always
          prevail over what the site shows.
        </li>
        <li>
          <strong>
            Before any transaction, the buyer must check the transfer conditions directly with
            the developer
          </strong>{" "}
          (official source linked on each developer page), and the seller must make sure their
          license can be transferred.
        </li>
      </ul>
      <p>
        To the fullest extent permitted by law, we aren&apos;t liable for losses resulting from
        reliance on this information. If you spot a mistake, tell us at {EMAIL} and we&apos;ll
        correct it quickly.
      </p>

      <h2>8. Trademarks and developers&apos; license terms</h2>
      <p>
        Plugin and developer names and logos are trademarks of their respective owners. They
        appear on the site only to identify the licenses that users offer for sale. Plugin
        Resale isn&apos;t affiliated with, sponsored or endorsed by any plugin developer. Every
        license stays subject to its developer&apos;s terms, and sellers alone are responsible
        for complying with them when they sell. A developer who believes a listing or the
        information about them is wrong or infringes their rights can write to {EMAIL} or use
        our <Link href="/report">report form</Link>; we&apos;ll review it promptly.
      </p>

      <h2>9. How listings are ranked</h2>
      <p>
        Browse shows the newest listings first by default. You can sort by price and filter by
        category, developer, price, transferable licenses and developer fee. No one can pay to
        rank higher, and we don&apos;t promote any seller&apos;s listings.
      </p>

      <h2>10. Reviews</h2>
      <p>
        Only the buyer and the seller of a completed deal can review each other, once each, with
        a rating from 1 to 5 and an optional comment. Reviews are published as written, with
        their date, newest first. We don&apos;t pay for reviews and we don&apos;t edit them; we
        check that a completed deal exists, but not what happened during it. We remove a review
        only if it breaks section 12 (for example, if it&apos;s abusive or off-topic).
      </p>

      <h2>11. Messages</h2>
      <p>
        Messages are for discussing a listing with the other party. We don&apos;t read them
        routinely, but we may look at a conversation when it&apos;s reported, or to prevent fraud.
      </p>

      <h2>12. Prohibited uses</h2>
      <p>You agree not to:</p>
      <ul>
        <li>List a license you don&apos;t own or aren&apos;t entitled to transfer.</li>
        <li>Sell as a business, or on behalf of someone else.</li>
        <li>Ask a buyer to pay with &quot;Friends &amp; Family&quot; instead of Goods &amp; Services.</li>
        <li>Post fake, abusive or misleading listings, messages or reviews.</li>
        <li>Scrape, spam, harass other users, or misuse the messaging or review system.</li>
        <li>Use the site for anything illegal, or try to circumvent these terms.</li>
      </ul>

      <h2>13. Reports and moderation</h2>
      <p>
        Anyone can report a listing, a user, a message or a review with our{" "}
        <Link href="/report">report form</Link>. Every report and moderation decision is reviewed
        by a person; we don&apos;t use automated moderation. If content breaks these terms or the
        law, we may remove it, and we may suspend or close the account behind it — temporarily
        or, for serious or repeated breaches, permanently. When we do, we tell you by email what
        we did and why. You can contest a decision by replying to that email or writing to{" "}
        {EMAIL}; we&apos;ll review it again. We may ignore reports that are manifestly
        unfounded.
      </p>

      <h2>14. Content you post</h2>
      <p>
        You keep ownership of what you post (listing descriptions, messages, reviews), but you
        allow us to display it on the site for as long as needed to run the marketplace.
      </p>

      <h2>15. Our role and liability</h2>
      <p>
        We provide a hosting and matchmaking service. Sales are concluded directly between
        users and we are not a party to them. We don&apos;t verify that a seller owns a license
        and we can&apos;t guarantee that a sale or a transfer will be completed. We are liable
        for our own failures in providing the service described in these terms. We aren&apos;t
        liable for what users post or do, unless we were told about clearly illegal content and
        didn&apos;t act promptly. Nothing in these terms limits liability that the law doesn&apos;t
        allow to be limited.
      </p>

      <h2>16. Taxes</h2>
      <p>
        Sellers are responsible for declaring any income from their sales where the law requires
        it (in France, see impots.gouv.fr and urssaf.fr). If the law requires it, we may share
        seller information with the tax authorities.
      </p>

      <h2>17. Closing your account</h2>
      <p>
        You can delete your account at any time from My account, once no purchase or sale is in
        progress. We may close an account under section 13.
      </p>

      <h2>18. Changes to these terms</h2>
      <p>
        We may update these terms as the site evolves. For any important change, we&apos;ll email
        you at least 15 days before it applies. If you don&apos;t agree, you can delete your
        account before then.
      </p>

      <h2>19. Consumer mediation</h2>
      <p>
        If you&apos;re a consumer and a complaint about our service hasn&apos;t been resolved
        after you wrote to us at {EMAIL}, you can refer it free of charge, within one year of
        your written complaint, to our consumer mediator: CM2C — Centre de la Médiation de la
        Consommation de Conciliateurs de Justice, 49 rue de Ponthieu, 75008 Paris, France —{" "}
        {CM2C}. Mediation covers disputes with us about the service; it doesn&apos;t cover sales
        between users, to which we aren&apos;t a party.
      </p>

      <h2>20. Governing law</h2>
      <p>
        These terms are governed by French law. If you&apos;re a consumer living in another
        country, you keep the protection of the mandatory rules of your country of residence.
      </p>

      <h2>21. Contact</h2>
      <p>Questions about these terms: {EMAIL}.</p>

      {/* ---------------------------------------------------------------- French version */}

      <section id="fr" lang="fr" className="legal-fr">
        <h1 className="page-title">Conditions générales d&apos;utilisation</h1>
        <p className="lead">Dernière mise à jour : 24 septembre 2026.</p>
        <p className="lang-switch">
          <a href="#en" lang="en">
            English version ↑
          </a>
        </p>

        <p>
          Plugin Resale (pluginresale.com) est exploité par SAS Boring Vic (« nous »), dont le
          siège est au 5 rue Henry Le Chatelier, 38000 Grenoble, France — 978 440 972 R.C.S.
          Grenoble. Toutes nos informations figurent dans les{" "}
          <Link href="/legal#fr">mentions légales</Link>. Vous pouvez nous écrire à {EMAIL}. Vous
          acceptez ces conditions lors de la création de votre compte, en cochant la case prévue
          à cet effet. Ces conditions existent en anglais et en français ; les deux versions ont
          la même valeur et, en cas de différence, la version française prévaut.
        </p>

        <h2>1. Ce qu&apos;est Plugin Resale</h2>
        <p>
          Plugin Resale est une plateforme sur laquelle des particuliers mettent en vente et
          achètent entre eux des licences de plugins audio d&apos;occasion. Nous hébergeons les
          annonces et mettons en relation acheteurs et vendeurs ; chaque vente est un contrat
          conclu uniquement entre l&apos;acheteur et le vendeur. La publication d&apos;annonces
          et l&apos;achat sont gratuits, et nous ne prenons aucune commission. Nous pourrons
          afficher de la publicité à l&apos;avenir, mais nous ne prélèverons jamais de part sur
          vos ventes.
        </p>

        <h2>2. Qui peut l&apos;utiliser</h2>
        <ul>
          <li>Vous devez avoir 18 ans ou plus.</li>
          <li>
            Plugin Resale est réservé aux particuliers qui revendent des licences achetées pour
            leur usage personnel. Les vendeurs professionnels (magasins, revendeurs, éditeurs,
            toute personne vendant dans le cadre d&apos;une activité professionnelle) ne peuvent
            pas publier d&apos;annonces.
          </li>
        </ul>

        <h2>3. Comptes</h2>
        <p>
          Un compte (email + lien de connexion, sans mot de passe) est nécessaire pour vendre,
          acheter, envoyer des messages ou laisser un avis. Utilisez une adresse email réelle et
          valide, un seul compte par personne, et tenez vos informations à jour. Vous êtes
          responsable de ce qui est fait depuis votre compte.
        </p>

        <h2>4. Vendre</h2>
        <p>Avant de publier une annonce, vous certifiez que :</p>
        <ul>
          <li>
            Vous êtes titulaire de la licence et il ne s&apos;agit pas d&apos;une licence NFR
            (Not-For-Resale), éducative ou fournie avec du matériel.
          </li>
          <li>
            Vous désinstallerez le plugin et effectuerez la procédure officielle de transfert de
            l&apos;éditeur une fois payé.
          </li>
          <li>
            Vous vendez en tant que particulier, et non dans le cadre d&apos;une activité
            professionnelle.
          </li>
        </ul>
        <p>
          Vous êtes responsable de l&apos;exactitude de votre annonce et de la vérification que
          votre licence peut être transférée selon les conditions de son éditeur. Publier une
          licence dont vous n&apos;êtes pas titulaire, ou dont l&apos;éditeur n&apos;autorise pas
          le transfert, constitue une violation des présentes conditions.
        </p>

        <h2>5. Acheter et payer</h2>
        <p>
          Plugin Resale n&apos;est jamais partie au paiement. Lorsque vous cliquez sur « Buy with
          PayPal », l&apos;annonce vous est réservée et l&apos;email PayPal du vendeur vous est
          affiché. Vous payez ensuite le vendeur directement via PayPal{" "}
          <strong>Biens et services</strong> (Goods &amp; Services) — jamais « Entre proches »
          (Friends &amp; Family). Nous ne traitons, ne détenons ni ne manipulons l&apos;argent à
          aucun moment, et ne prélevons aucun frais. Votre paiement peut être couvert par la
          Protection des achats PayPal, selon les conditions propres à PayPal, que nous ne
          maîtrisons pas. Chaque partie peut annuler l&apos;achat tant que le vendeur n&apos;a pas
          confirmé la réception du paiement.
        </p>
        <p>
          Avant de payer, l&apos;acheteur doit vérifier les conditions de transfert auprès de
          l&apos;éditeur (voir article 7). Tous les vendeurs étant des particuliers, les droits
          des consommateurs applicables aux achats auprès d&apos;un professionnel (notamment le
          droit de rétractation de 14 jours et la garantie légale de conformité) ne
          s&apos;appliquent pas à ces ventes. Le droit commun des contrats entre particuliers
          reste applicable.
        </p>

        <h2>6. Problèmes entre acheteur et vendeur</h2>
        <p>
          Si un paiement ou un transfert de licence se passe mal, contactez d&apos;abord
          l&apos;autre utilisateur puis, si nécessaire, ouvrez un litige dans le Centre de
          résolution PayPal. Nous n&apos;intervenons pas comme médiateur entre utilisateurs et
          n&apos;effectuons aucun remboursement. Nous agissons en revanche sur les signalements de
          fraude ou d&apos;abus (voir article 13) et coopérons avec les autorités lorsque la loi
          l&apos;exige.
        </p>

        <h2>7. Règles de transfert des éditeurs : à titre informatif uniquement</h2>
        <p>
          Les règles de transfert des éditeurs affichées sur le site (frais, procédure, délais,
          restrictions, mention « transférable » et filtres qui s&apos;y rapportent) sont un
          résumé que nous établissons gratuitement à partir des informations publiques de chaque
          éditeur. Ces informations sont fournies{" "}
          <strong>« en l&apos;état », à titre purement informatif</strong> :
        </p>
        <ul>
          <li>
            Les éditeurs peuvent modifier leur politique à tout moment sans nous en informer. Nous
            ne garantissons pas que ces informations soient exactes, complètes ou à jour, même
            lorsqu&apos;une date de dernière vérification est affichée.
          </li>
          <li>
            Elles ne constituent ni un conseil juridique, ni une déclaration faite par un éditeur
            ou en son nom. Les conditions de licence (EULA) et la politique de transfert de
            l&apos;éditeur prévalent toujours sur les informations affichées sur le site.
          </li>
          <li>
            <strong>
              Avant toute transaction, il incombe à l&apos;acheteur de vérifier les conditions de
              transfert directement auprès de l&apos;éditeur
            </strong>{" "}
            (source officielle indiquée sur chaque page éditeur), et au vendeur de s&apos;assurer
            que sa licence est transférable.
          </li>
        </ul>
        <p>
          Dans toute la mesure permise par la loi, nous ne sommes pas responsables des préjudices
          résultant de l&apos;utilisation de ces informations. Si vous constatez une erreur,
          signalez-la à {EMAIL} : nous la corrigerons rapidement.
        </p>

        <h2>8. Marques et conditions de licence des éditeurs</h2>
        <p>
          Les noms et logos des plugins et des éditeurs sont des marques appartenant à leurs
          titulaires respectifs. Ils apparaissent sur le site uniquement pour identifier les
          licences que les utilisateurs mettent en vente. Plugin Resale n&apos;est ni affilié à
          un éditeur de plugins, ni sponsorisé ou approuvé par l&apos;un d&apos;eux. Chaque
          licence reste soumise aux conditions de son éditeur, et le vendeur est seul responsable
          de leur respect lorsqu&apos;il vend. Un éditeur qui estime qu&apos;une annonce ou
          qu&apos;une information le concernant est erronée ou porte atteinte à ses droits peut
          écrire à {EMAIL} ou utiliser notre{" "}
          <Link href="/report">formulaire de signalement</Link> ; nous l&apos;examinerons
          rapidement.
        </p>

        <h2>9. Classement des annonces</h2>
        <p>
          La page Browse affiche par défaut les annonces les plus récentes en premier. Vous pouvez
          les trier par prix et les filtrer par catégorie, éditeur, prix, licences transférables
          et frais de l&apos;éditeur. Personne ne peut payer pour être mieux classé, et nous ne
          mettons en avant les annonces d&apos;aucun vendeur.
        </p>

        <h2>10. Avis</h2>
        <p>
          Seuls l&apos;acheteur et le vendeur d&apos;une vente conclue peuvent s&apos;évaluer
          mutuellement, une fois chacun, avec une note de 1 à 5 et un commentaire facultatif. Les
          avis sont publiés tels qu&apos;ils sont rédigés, avec leur date, du plus récent au plus
          ancien. Nous ne rémunérons pas les avis et ne les modifions pas ; nous vérifions
          qu&apos;une vente conclue existe, mais pas son déroulement. Nous ne retirons un avis
          que s&apos;il enfreint l&apos;article 12 (par exemple s&apos;il est injurieux ou hors
          sujet).
        </p>

        <h2>11. Messages</h2>
        <p>
          La messagerie sert à échanger avec l&apos;autre partie au sujet d&apos;une annonce. Nous
          ne lisons pas les messages de manière systématique, mais nous pouvons consulter une
          conversation lorsqu&apos;elle nous est signalée, ou pour prévenir la fraude.
        </p>

        <h2>12. Utilisations interdites</h2>
        <p>Vous vous engagez à ne pas :</p>
        <ul>
          <li>
            Mettre en vente une licence dont vous n&apos;êtes pas titulaire ou que vous
            n&apos;avez pas le droit de transférer.
          </li>
          <li>Vendre à titre professionnel, ou pour le compte d&apos;un tiers.</li>
          <li>
            Demander à un acheteur de payer via « Entre proches » (Friends &amp; Family) au lieu
            de « Biens et services ».
          </li>
          <li>Publier des annonces, messages ou avis faux, injurieux ou trompeurs.</li>
          <li>
            Aspirer les données du site, envoyer du spam, harceler d&apos;autres utilisateurs ou
            détourner la messagerie ou le système d&apos;avis.
          </li>
          <li>
            Utiliser le site à des fins illicites, ou tenter de contourner les présentes
            conditions.
          </li>
        </ul>

        <h2>13. Signalements et modération</h2>
        <p>
          Toute personne peut signaler une annonce, un utilisateur, un message ou un avis via
          notre <Link href="/report">formulaire de signalement</Link>. Chaque signalement et
          chaque décision de modération sont examinés par une personne ; nous n&apos;utilisons pas
          de modération automatisée. Si un contenu enfreint les présentes conditions ou la loi,
          nous pouvons le retirer et suspendre ou fermer le compte concerné — temporairement ou,
          en cas de manquement grave ou répété, définitivement. Nous vous indiquons alors par
          email la mesure prise et ses motifs. Vous pouvez contester une décision en répondant à
          cet email ou en écrivant à {EMAIL} ; nous la réexaminerons. Nous pouvons ne pas donner
          suite aux signalements manifestement infondés.
        </p>

        <h2>14. Contenus que vous publiez</h2>
        <p>
          Vous restez propriétaire de ce que vous publiez (descriptions d&apos;annonces, messages,
          avis), mais vous nous autorisez à l&apos;afficher sur le site aussi longtemps que
          nécessaire au fonctionnement de la plateforme.
        </p>

        <h2>15. Notre rôle et notre responsabilité</h2>
        <p>
          Nous fournissons un service d&apos;hébergement et de mise en relation. Les ventes sont
          conclues directement entre utilisateurs et nous n&apos;y sommes pas partie. Nous ne
          vérifions pas qu&apos;un vendeur est titulaire d&apos;une licence et ne pouvons pas
          garantir qu&apos;une vente ou un transfert aboutira. Nous sommes responsables de nos
          propres manquements dans la fourniture du service décrit dans les présentes conditions.
          Nous ne sommes pas responsables de ce que les utilisateurs publient ou font, sauf si,
          informés d&apos;un contenu manifestement illicite, nous n&apos;avons pas agi
          promptement. Aucune stipulation des présentes ne limite une responsabilité que la loi
          interdit de limiter.
        </p>

        <h2>16. Fiscalité</h2>
        <p>
          Les vendeurs sont responsables de la déclaration des revenus éventuellement tirés de
          leurs ventes lorsque la loi l&apos;exige (en France, voir impots.gouv.fr et urssaf.fr).
          Si la loi l&apos;impose, nous pouvons transmettre des informations sur les vendeurs à
          l&apos;administration fiscale.
        </p>

        <h2>17. Fermeture de votre compte</h2>
        <p>
          Vous pouvez supprimer votre compte à tout moment depuis la page My account, dès lors
          qu&apos;aucun achat ni aucune vente n&apos;est en cours. Nous pouvons fermer un compte
          dans les conditions de l&apos;article 13.
        </p>

        <h2>18. Modification des conditions</h2>
        <p>
          Nous pouvons modifier ces conditions pour accompagner l&apos;évolution du site. Pour
          toute modification importante, nous vous préviendrons par email au moins 15 jours avant
          son entrée en vigueur. Si vous n&apos;êtes pas d&apos;accord, vous pouvez supprimer
          votre compte d&apos;ici là.
        </p>

        <h2>19. Médiation de la consommation</h2>
        <p>
          Si vous êtes consommateur et qu&apos;une réclamation concernant notre service n&apos;a
          pas été résolue après nous avoir écrit à {EMAIL}, vous pouvez saisir gratuitement,
          dans un délai d&apos;un an à compter de votre réclamation écrite, notre médiateur de la
          consommation : CM2C — Centre de la Médiation de la Consommation de Conciliateurs de
          Justice, 49 rue de Ponthieu, 75008 Paris — {CM2C}. La médiation porte sur les litiges
          qui vous opposent à nous au sujet du service ; elle ne couvre pas les ventes entre
          utilisateurs, auxquelles nous ne sommes pas partie.
        </p>

        <h2>20. Droit applicable</h2>
        <p>
          Les présentes conditions sont régies par le droit français. Si vous êtes un
          consommateur résidant dans un autre pays, vous conservez la protection des dispositions
          impératives de la loi de votre pays de résidence.
        </p>

        <h2>21. Contact</h2>
        <p>Pour toute question sur ces conditions : {EMAIL}.</p>
      </section>
    </main>
  );
}
