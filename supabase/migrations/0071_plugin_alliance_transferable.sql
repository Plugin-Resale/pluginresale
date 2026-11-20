-- 0071: Plugin Alliance transfers are possible again, and the owner changed.
--
-- Reported by a visitor (Matthew, email of 19 Nov 2026): the source link on the
-- developer page returned an error page, and the row said Native Instruments owned
-- Plugin Alliance.
--
-- 1. Ownership: Dirk Ulrich, the founder, bought Brainworx and Plugin Alliance back
--    from the Native Instruments group on 14 July 2026. Both are now part of his
--    RCKFRC group, with Apogee and Manley. Source, Plugin Alliance own news page
--    https://www.plugin-alliance.com/blogs/news/a-letter-from-the-founder
--    The mention of Native Instruments lived in the process text, replaced below.
--
-- 2. Policy: the old support article is gone, which is why the link broke. The new
--    one, How do I transfer a plugin license, last updated 9 Oct 2026, explains how
--    to transfer a license, so transfers are allowed again, not refused.
--    https://support.plugin-alliance.com/hc/en-us/articles/52323567089428-How-do-I-transfer-a-plugin-license
--    It states no fee, no delay and no excluded license type, so those stay empty.
--    The EULA Transfer clause is the second official source for the conditions.

update public.developers set
  transferable = true,
  fee = null,
  who_pays = null,
  process = 'The seller sends a request to Plugin Alliance customer support with three things: the email of the account that holds the license, the email of the recipient Plugin Alliance account, and the exact name of each plug-in to transfer. Plugin Alliance moves the license between the two accounts.',
  typical_delay = null,
  restrictions = 'Plugin Alliance publishes no fee, no delay and no excluded license type for transfers. Its EULA (Transfer) ends the seller license as soon as the software is transferred, and the buyer has to accept the EULA. The old policy, 20 dollars per plug-in with a 50 dollar maximum paid by the buyer and subscription or already transferred licenses excluded, is no longer published: ask support what applies to your license.',
  source_url = 'https://support.plugin-alliance.com/hc/en-us/articles/52323567089428-How-do-I-transfer-a-plugin-license',
  last_verified = '2026-11-20'
where slug = 'plugin-alliance';
