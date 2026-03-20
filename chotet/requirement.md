\*\*SOFTWARE REQUIREMENTS SPECIFICATION\*\*



\_IEEE Std 830-1998 Compliant\_



─────────────────────────────────────────────



\*\*ChoTet\*\*



\_Smart Tet Shopping Manager\_



A Flutter Mobile Application



| \*\*Field\*\* | \*\*Detail\*\* |

| --- | --- |

| Document Version | 1.0 |

| Application Name | ChoTet |

| Platform | Flutter - Android \& iOS |

| Storage | Local only (SQLite / Hive) |

| Project Type | Solo Academic Project |

| Status | Draft |



\# \*\*Revision History\*\*



| \*\*Version\*\* | \*\*Date\*\* | \*\*Author\*\* | \*\*Description\*\* |

| --- | --- | --- | --- |

| 1.0 | 2025 | Student | Initial draft - full requirements |



\# \*\*1\\. Introduction\*\*



\## \*\*1.1 Purpose\*\*



This Software Requirements Specification (SRS) defines the functional and non-functional requirements for ChoTet, a Flutter-based mobile application designed to help Vietnamese users plan and manage their Tet holiday shopping efficiently. The document follows the IEEE 830-1998 standard and serves as the primary reference for design, development, and testing of the application.



\## \*\*1.2 Scope\*\*



ChoTet is a mobile application targeting Android and iOS platforms, built with Flutter. All data is stored locally on the user's device using SQLite or Hive - no internet connection is required.



The application covers the following capabilities:



\- Create and manage Tet shopping lists with items, quantities, and categories

\- Track estimated and actual costs against a user-defined budget

\- Compare item prices across multiple shops entered manually by the user

\- Organise items by predefined market zones to optimise the shopping route



Out of scope for v1.0:



\- Cloud synchronisation or multi-device support

\- Real-time price data from external APIs or web scraping

\- Social or family sharing features

\- AI/ML-based recommendations



\## \*\*1.3 Definitions, Acronyms, and Abbreviations\*\*



| \*\*Term\*\* | \*\*Definition\*\* |

| --- | --- |

| SRS | Software Requirements Specification |

| FR  | Functional Requirement |

| NFR | Non-Functional Requirement |

| UC  | Use Case |

| Tet | Vietnamese Lunar New Year - the primary occasion this app is designed for |

| Market Zone | A predefined section of a traditional Vietnamese market (e.g. Meat \& Fish, Vegetables, Dry Goods) |

| Shopping List | A user-created list of items to purchase during a Tet shopping trip |

| Budget | The maximum total amount the user plans to spend |

| Price Record | A manually entered price for a specific item at a specific shop |

| Flutter | Google's open-source UI toolkit for building natively compiled mobile apps from a single codebase |

| SQLite | A lightweight, file-based relational database used for local on-device storage |

| Hive | A fast, lightweight NoSQL key-value database for Flutter |



\## \*\*1.4 References\*\*



\- IEEE Std 830-1998 - IEEE Recommended Practice for Software Requirements Specifications

\- Flutter Documentation - <https://flutter.dev/docs>

\- sqflite package - <https://pub.dev/packages/sqflite>

\- Hive package - <https://pub.dev/packages/hive>



\## \*\*1.5 Overview\*\*



The remainder of this document is structured as follows:



\- Section 2 provides an overall description of the product, its context, assumptions, and constraints.

\- Section 3 defines all specific functional requirements organised by feature module.

\- Section 4 defines non-functional requirements covering performance, usability, reliability, and security.

\- Section 5 presents the data model.

\- Section 6 presents use cases.

\- Section 7 defines UI/UX requirements.

\- Section 8 outlines the development roadmap.



\# \*\*2\\. Overall Description\*\*



\## \*\*2.1 Product Perspective\*\*



ChoTet is a standalone mobile application with no external system dependencies. It operates entirely offline, reading from and writing to a local database on the user's device. The diagram below illustrates the system context:



| \*\*Layer\*\* | \*\*Technology\*\* | \*\*Responsibility\*\* |

| --- | --- | --- |

| Presentation | Flutter Widgets | All UI screens and navigation |

| Business Logic | Dart / Provider | Feature logic, calculations, state management |

| Data Access | Repository Pattern | Abstracts SQLite/Hive operations |

| Storage | SQLite (sqflite) or Hive | Persistent local data storage on device |



\## \*\*2.2 Product Functions - High Level\*\*



The four core function groups of ChoTet are:



\- Shopping List Management - create lists, add/edit/delete items, check off purchased items.

\- Budget \& Cost Tracking - set a budget, track estimated vs. actual spend, view trip summary.

\- Price Comparison - manually record item prices at different shops and compare them side by side.

\- Market Zone Navigation - items grouped by predefined zones to guide an efficient shopping route.



\## \*\*2.3 User Characteristics\*\*



| \*\*User Group\*\* | \*\*Profile\*\* | \*\*Key Need\*\* |

| --- | --- | --- |

| Homemakers / Parents | 30-55 yrs, primary shoppers | Full list management, budget control |

| Working Adults | 22-40 yrs, limited time | Quick check-off, zone routing |

| Students | 18-25 yrs, tech-savvy | Price comparison, saving money |

| Older Adults | 55+, less tech experience | Simple UI, large text, clear icons |



\## \*\*2.4 Constraints\*\*



\- C-01: The application must run on Flutter (Dart) targeting Android 6.0+ and iOS 12+.

\- C-02: No internet connection may be required for any core feature.

\- C-03: All data must be stored locally on-device; no external server communication.

\- C-04: The application is developed by a single developer (solo project).

\- C-05: The UI language is English; Vietnamese item names are supported as user input.



\## \*\*2.5 Assumptions and Dependencies\*\*



\- A-01: Users own a smartphone running Android 6.0+ or iOS 12+.

\- A-02: Users are comfortable entering data manually (prices, item names, quantities).

\- A-03: The sqflite or Hive package is used; the choice will be finalised during detailed design.

\- A-04: Market zone names and categories are predefined by the developer and shipped with the app.



\# \*\*3\\. Specific Functional Requirements\*\*



Requirements are labelled FR-XX, prioritised as Must Have (M), Should Have (S), or Could Have (C).



\## \*\*3.1 Shopping List Management\*\*



\### \*\*3.1.1 List Operations\*\*



| \*\*ID\*\* | \*\*Requirement\*\* | \*\*Priority\*\* |

| --- | --- | --- |

| FR-01 | The user shall be able to create a new shopping list with a name and optional budget. | M   |

| FR-02 | The system shall provide at least three pre-populated list templates for common Tet shopping scenarios (e.g. Full Tet Grocery, Tet Gift Basket, Home Decoration). | M   |

| FR-03 | The user shall be able to rename, duplicate, or delete any existing list. | M   |

| FR-04 | The app shall display all lists on a home screen sorted by creation date (newest first). | M   |

| FR-05 | Each list shall show a summary badge: total items, items purchased, and estimated total cost. | M   |



\### \*\*3.1.2 Item Operations\*\*



| \*\*ID\*\* | \*\*Requirement\*\* | \*\*Priority\*\* |

| --- | --- | --- |

| FR-06 | The user shall be able to add an item to a list with the following fields: name (required), quantity, unit of measure, estimated unit price, and market zone. | M   |

| FR-07 | The system shall provide a searchable catalog of common Tet items (e.g. chicken, sticky rice, spring rolls, dried fruit, flowers) to speed up item entry. | M   |

| FR-08 | The user shall be able to edit any field of an existing item at any time. | M   |

| FR-09 | The user shall be able to delete an item from the list with a confirmation prompt. | M   |

| FR-10 | The user shall be able to mark an item as Purchased by tapping a checkbox. Purchased items shall be visually distinguished (strikethrough + greyed out). | M   |

| FR-11 | The user shall be able to undo a purchase check within 5 seconds via a Snackbar action. | M   |

| FR-12 | Items shall be grouped by their assigned market zone within the list view. | M   |

| FR-13 | The user shall be able to filter the list to show All items, Pending items only, or Purchased items only. | M   |

| FR-14 | The user shall be able to search items within a list by name. | S   |

| FR-15 | The user shall be able to attach an optional photo to an item by capturing with the camera or selecting from the gallery. | C   |



\## \*\*3.2 Budget and Cost Tracking\*\*



| \*\*ID\*\* | \*\*Requirement\*\* | \*\*Priority\*\* |

| --- | --- | --- |

| FR-16 | The user shall be able to set a total budget (in VND) for each shopping list. | M   |

| FR-17 | The system shall calculate and display the Total Estimated Cost as the sum of (quantity x estimated unit price) across all items in the list. | M   |

| FR-18 | The system shall display a budget progress bar showing: estimated cost vs. budget, and actual spend vs. budget. | M   |

| FR-19 | The system shall show a visual warning (e.g. progress bar turns red) when the estimated cost exceeds 90% of the budget. | M   |

| FR-20 | The system shall show an alert when the estimated cost exceeds the budget. | M   |

| FR-21 | The user shall be able to enter the Actual Price paid for each item after purchase. | M   |

| FR-22 | The system shall calculate Actual Total Spend as the sum of (quantity x actual price) for all purchased items. | M   |

| FR-23 | Upon completing a trip, the system shall display a Trip Summary screen showing: total estimated cost, total actual spend, budget remaining or overspent, and number of items purchased vs. total. | M   |

| FR-24 | The system shall store completed trip summaries as Shopping History entries viewable later. | S   |



\## \*\*3.3 Price Comparison\*\*



| \*\*ID\*\* | \*\*Requirement\*\* | \*\*Priority\*\* |

| --- | --- | --- |

| FR-25 | The user shall be able to add multiple shop names as price comparison sources (e.g. Ben Thanh Market, Co.opmart, Vinmart, Local Market). | M   |

| FR-26 | For any item in the list, the user shall be able to record a price at each registered shop. | M   |

| FR-27 | The system shall display a Price Comparison Table for each item showing all recorded shop prices side by side. | M   |

| FR-28 | The system shall automatically highlight the lowest price in green and the highest price in red in the comparison table. | M   |

| FR-29 | The system shall calculate and display the price difference (absolute in VND and percentage) between the cheapest and most expensive options. | M   |

| FR-30 | The system shall provide a Cart Optimiser view that, given the full shopping list, calculates the cheapest total cost if the user buys all items at the single cheapest shop per item. | S   |

| FR-31 | Price records shall persist locally so that historical prices are available as reference on the next use. | S   |



\## \*\*3.4 Market Zone Navigation\*\*



| \*\*ID\*\* | \*\*Requirement\*\* | \*\*Priority\*\* |

| --- | --- | --- |

| FR-32 | The system shall include the following predefined market zones shipped with the app: (1) Fresh Meat \& Seafood, (2) Vegetables \& Herbs, (3) Dry Goods \& Pantry, (4) Tet Confectionery \& Dried Fruits, (5) Tet Cakes \& Charcuterie, (6) Beverages, (7) Fresh Flowers \& Plants, (8) Tet Gifts \& Hampers, (9) Home Decoration. | M   |

| FR-33 | When adding an item, the system shall suggest a zone based on keyword matching of the item name (e.g. 'chicken' -> Fresh Meat \& Seafood). | M   |

| FR-34 | The user shall be able to manually override the suggested zone for any item. | M   |

| FR-35 | The Zone View shall display items grouped by zone in a recommended visiting order (optimised to minimise backtracking in a typical Vietnamese market layout). | M   |

| FR-36 | The user shall be able to mark an entire zone as Done to collapse it and focus on remaining zones. | M   |

| FR-37 | The system shall display a zone progress indicator showing how many zones have been fully purchased. | S   |



\## \*\*3.5 Export and Sharing\*\*



| \*\*ID\*\* | \*\*Requirement\*\* | \*\*Priority\*\* |

| --- | --- | --- |

| FR-38 | The user shall be able to export a shopping list as a PDF file to the device storage. | S   |

| FR-39 | The exported PDF shall include: list name, all items with quantities and estimated prices, total estimated cost, and budget. | S   |

| FR-40 | The user shall be able to share the exported PDF via the system share sheet (e.g. Zalo, Messenger, Email). | C   |



\## \*\*3.6 Application Settings\*\*



| \*\*ID\*\* | \*\*Requirement\*\* | \*\*Priority\*\* |

| --- | --- | --- |

| FR-41 | The user shall be able to switch between Light Mode and Dark Mode. | S   |

| FR-42 | The user shall be able to choose a currency display format (e.g. 1,000,000 VND or 1.000.000 VND). | S   |

| FR-43 | The user shall be able to delete all app data (factory reset) with a confirmation dialog. | M   |



\# \*\*4\\. Non-Functional Requirements\*\*



\## \*\*4.1 Performance\*\*



\- NFR-01: The application shall launch and reach the home screen within 3 seconds on a mid-range device (2 GB RAM, Android 8+).

\- NFR-02: All CRUD operations (add, edit, delete items) shall complete and reflect in the UI within 500 ms.

\- NFR-03: The price comparison table shall render within 1 second for lists of up to 100 items and 10 shops.

\- NFR-04: The application shall function fully without an internet connection at all times.



\## \*\*4.2 Usability\*\*



\- NFR-05: A first-time user shall be able to create a list and add 5 items within 2 minutes without reading any documentation.

\- NFR-06: All interactive elements (buttons, checkboxes) shall have a minimum touch target size of 48x48 dp, following Material Design guidelines.

\- NFR-07: The application shall support both Light and Dark modes.

\- NFR-08: Text shall be legible at default system font sizes; the layout shall not break if the user increases system font size by up to 150%.

\- NFR-09: Vietnamese characters shall render correctly throughout the app (item names, zone names, etc.).



\## \*\*4.3 Reliability\*\*



\- NFR-10: No data loss shall occur when the application is closed or crashes mid-session; all confirmed actions shall be persisted immediately to the local database.

\- NFR-11: The application shall handle empty states gracefully (e.g. empty list, no price records) with informative placeholder messages rather than errors.

\- NFR-12: The application shall not crash on any standard user interaction defined in this SRS.



\## \*\*4.4 Security \& Privacy\*\*



\- NFR-13: All user data shall be stored exclusively on the device; no data shall be transmitted to any external server.

\- NFR-14: The application shall request only permissions strictly necessary: camera (item photo, optional) and storage (PDF export, optional).

\- NFR-15: No analytics or telemetry data shall be collected.



\## \*\*4.5 Maintainability\*\*



\- NFR-16: The codebase shall follow a layered architecture (Presentation / Business Logic / Data), either MVVM or Clean Architecture.

\- NFR-17: Each feature module shall be self-contained to allow independent modification without affecting other modules.

\- NFR-18: All hardcoded strings (zone names, category names, error messages) shall be extracted into a constants file to facilitate future localisation.



\## \*\*4.6 Portability\*\*



\- NFR-19: The application shall run on Android 6.0 (API 23) and above.

\- NFR-20: The application shall run on iOS 12.0 and above.

\- NFR-21: The UI shall adapt correctly to common screen sizes: 5.0", 6.1", 6.7" displays in both portrait and landscape orientations.



\# \*\*5\\. Data Model\*\*



All entities are stored locally. The following table describes each entity and its key attributes.



| \*\*Entity\*\* | \*\*Key Attributes\*\* | \*\*Notes\*\* |

| --- | --- | --- |

| ShoppingList | id (PK), name, budget (VND), createdAt, isCompleted | One user can have many lists |

| ShoppingItem | id (PK), listId (FK), name, quantity, unit, estimatedPrice, actualPrice, category, zoneId, isPurchased, imageUri | Each item belongs to one list and one zone |

| MarketZone | id (PK), name, visitOrder, iconName | Predefined; 9 zones shipped with the app |

| PriceRecord | id (PK), itemName, shopName, price, recordedAt | Prices entered manually; persisted for reference |

| TripSummary | id (PK), listId (FK), totalEstimated, totalActual, budget, completedAt | Created when user marks a trip as complete |



Entity Relationships:



\- ShoppingList 1 --< ShoppingItem (one list has many items)

\- MarketZone 1 --< ShoppingItem (one zone contains many items)

\- ShoppingList 1 -- 1 TripSummary (one completed list produces one summary)

\- PriceRecord is independent; matched to items by item name string



\# \*\*6\\. Use Cases\*\*



\## \*\*6.1 Use Case Summary\*\*



| \*\*UC ID\*\* | \*\*Use Case Name\*\* | \*\*Actor\*\* | \*\*Related FRs\*\* |

| --- | --- | --- | --- |

| UC-01 | Create a new shopping list | User | FR-01, FR-02 |

| UC-02 | Add an item to a list | User | FR-06, FR-07, FR-32, FR-33 |

| UC-03 | Check off a purchased item | User | FR-10, FR-11, FR-22 |

| UC-04 | Set and track budget | User | FR-16, FR-17, FR-18, FR-19, FR-20 |

| UC-05 | Enter actual price after purchase | User | FR-21, FR-22 |

| UC-06 | Compare item prices across shops | User | FR-25, FR-26, FR-27, FR-28, FR-29 |

| UC-07 | Navigate shopping by market zone | User | FR-35, FR-36, FR-37 |

| UC-08 | View trip summary | User | FR-23, FR-24 |

| UC-09 | Export shopping list to PDF | User | FR-38, FR-39, FR-40 |

| UC-10 | View shopping history | User | FR-24 |



\## \*\*6.2 Detailed Use Case - UC-03: Check Off a Purchased Item\*\*



| \*\*Field\*\* | \*\*Description\*\* |

| --- | --- |

| Use Case ID | UC-03 |

| Use Case Name | Check Off a Purchased Item |

| Actor | User |

| Precondition | A shopping list exists with at least one unpurchased item. |

| Trigger | User taps the checkbox next to an item. |

| Main Flow | 1\\. User opens a shopping list. 2. User locates the target item. 3. User taps the checkbox. 4. System marks the item as Purchased, applies strikethrough styling, and moves it to the Purchased section. 5. System recalculates Actual Spend. 6. A Snackbar appears with an Undo option for 5 seconds. |

| Alternative Flow | 3a. User swipes the item row to the right - system performs the same check-off action. |

| Exception Flow | 3b. If a database write error occurs, system shows an error toast and reverts the UI state. |

| Postcondition | Item is marked as Purchased in the database; Actual Spend is updated; budget progress bar reflects the change. |



\## \*\*6.3 Detailed Use Case - UC-06: Compare Item Prices Across Shops\*\*



| \*\*Field\*\* | \*\*Description\*\* |

| --- | --- |

| Use Case ID | UC-06 |

| Use Case Name | Compare Item Prices Across Shops |

| Actor | User |

| Precondition | At least one shop has been added and at least one price record exists. |

| Trigger | User navigates to the Price Comparison screen for an item. |

| Main Flow | 1\\. User opens an item's detail screen. 2. User taps 'Compare Prices'. 3. System displays a table: rows = shops, columns = item name and price. 4. System highlights the cheapest price in green and the most expensive in red. 5. System displays the price difference in VND and percentage. 6. User can tap 'Add Price' to record a new price at a new shop. |

| Alternative Flow | 6a. User edits an existing price record by long-pressing a row. |

| Exception Flow | If no price records exist, system shows an empty state message: 'No prices recorded yet. Tap + to add one.' |

| Postcondition | Price records are saved locally. Comparison table is updated. |



\# \*\*7\\. User Interface Requirements\*\*



\## \*\*7.1 Screen Structure\*\*



| \*\*Screen\*\* | \*\*Access\*\* | \*\*Purpose\*\* |

| --- | --- | --- |

| Home | App launch | List all shopping lists, create new list |

| List Detail | Tap a list | View/edit items, filter, check off |

| Add/Edit Item | FAB or item tap | Enter item details, assign zone |

| Zone View | Tab in List Detail | Items grouped by market zone in visit order |

| Price Comparison | Item detail screen | Record and compare prices across shops |

| Budget Dashboard | Tab in List Detail | Budget progress, estimated vs actual spend |

| Trip Summary | Complete trip button | Final spend breakdown and savings |

| Shopping History | Main menu | Past completed trips |

| Settings | Main menu | Theme, currency format, data management |



\## \*\*7.2 Navigation\*\*



\- The app shall use a Bottom Navigation Bar with 4 tabs: Lists, Zone Map, Prices, Settings.

\- A Floating Action Button (+) shall be available on the Home and List Detail screens for quick item/list creation.

\- Swipe-to-dismiss shall be supported for deleting items (left swipe) and checking off items (right swipe).



\## \*\*7.3 Visual Design\*\*



\- Color Palette: Primary red #C0392B (Tet red), accent gold #E67E22, background #FAFAFA (light) / #1A1A1A (dark).

\- Typography: Use a Vietnamese-compatible font (e.g. Roboto or Nunito via Google Fonts).

\- The UI shall include subtle Tet-themed decorative elements (e.g. plum blossom motifs in header) without cluttering the functional layout.

\- Status indicators: green for under budget / purchased, red for over budget / warning, grey for inactive.



\## \*\*7.4 Accessibility\*\*



\- Minimum contrast ratio of 4.5:1 for all body text (WCAG AA).

\- All icons shall have semantic labels for screen readers.

\- The layout shall not break when the user enables Bold Text on iOS or increases font size on Android.



\# \*\*8\\. Development Roadmap\*\*



Given the solo nature of this project, features are prioritised into three phases:



| \*\*Phase\*\* | \*\*Duration\*\* | \*\*Features Delivered\*\* |

| --- | --- | --- |

| Phase 1 - MVP | Weeks 1-4 | Shopping list CRUD, item check-off, predefined zones, basic budget tracking, home screen |

| Phase 2 - Core | Weeks 5-8 | Price comparison (manual), zone navigation view, budget progress bar, trip summary, shopping history |

| Phase 3 - Polish | Weeks 9-12 | PDF export, dark mode, settings screen, item photo, Tet catalog auto-suggest, UX polish \& bug fixing |



\# \*\*9\\. Risks and Mitigations\*\*



| \*\*Risk\*\* | \*\*Likelihood\*\* | \*\*Impact\*\* | \*\*Mitigation\*\* |

| --- | --- | --- | --- |

| Data loss on app crash | Low | High | Write to DB immediately on every user action; use transactions |

| SQLite vs Hive migration overhead | Medium | Medium | Decide storage engine before Phase 1 begins; abstract via Repository pattern |

| Vietnamese text rendering issues | Low | Medium | Test on real devices early; use Google Fonts with Vietnamese subset |

| PDF export library compatibility | Medium | Low | Evaluate pdf package on pub.dev in Phase 2; have fallback plain-text export |

| Feature creep in solo timeline | High | High | Strictly follow phase priorities; treat Phase 3 as optional stretch goals |



\# \*\*Appendix A - Predefined Market Zones\*\*



| \*\*Zone ID\*\* | \*\*Zone Name\*\* | \*\*Visit Order\*\* | \*\*Typical Items\*\* |

| --- | --- | --- | --- |

| Z-01 | Fresh Meat \& Seafood | 1   | Chicken, pork, beef, shrimp, fish, squid |

| Z-02 | Vegetables \& Herbs | 2   | Spring onion, garlic, chili, coriander, fresh greens |

| Z-03 | Dry Goods \& Pantry | 3   | Sticky rice, mung beans, fish sauce, cooking oil, dried onion |

| Z-04 | Tet Confectionery \& Dried Fruits | 4   | Coconut jam, ginger candy, roasted watermelon seeds, o mai |

| Z-05 | Tet Cakes \& Charcuterie | 5   | Banh chung, banh tet, cha lua, gio thu, pate |

| Z-06 | Beverages | 6   | Beer, soft drinks, fruit juice, tea, wine |

| Z-07 | Fresh Flowers \& Plants | 7   | Peach blossom, apricot blossom, chrysanthemum, kumquat tree |

| Z-08 | Tet Gifts \& Hampers | 8   | Gift hampers, wine sets, tea boxes, cashew nuts |

| Z-09 | Home Decoration | 9   | Lanterns, couplets, Tet calendar, artificial flowers |



\# \*\*Appendix B - Common Tet Item Catalog (Sample)\*\*



The following items are pre-loaded into the app's searchable catalog:



| \*\*Item Name\*\* | \*\*Default Zone\*\* | \*\*Default Unit\*\* |

| --- | --- | --- |

| Chicken (whole) | Fresh Meat \& Seafood | kg  |

| Pork belly | Fresh Meat \& Seafood | kg  |

| Sticky rice | Dry Goods \& Pantry | kg  |

| Mung beans | Dry Goods \& Pantry | kg  |

| Banh chung | Tet Cakes \& Charcuterie | piece |

| Cha lua (pork roll) | Tet Cakes \& Charcuterie | pack |

| Coconut jam | Tet Confectionery | jar |

| Watermelon seeds | Tet Confectionery | pack |

| Beer (case) | Beverages | case |

| Soft drinks | Beverages | can |

| Peach blossom | Fresh Flowers \& Plants | branch |

| Kumquat tree | Fresh Flowers \& Plants | pot |

| Lanterns | Home Decoration | piece |

| Tet gift hamper | Tet Gifts \& Hampers | box |



\*\*\_- End of Document -\_\*\*



\_ChoTet SRS v1.0 | Solo Flutter Project | IEEE 830-1998\_

