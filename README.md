# XKCD Comic Viewer

This is my solution to the coding assignment for iOS by Shortcut.
The coding assignment can be found here [coding-assignment-mobile](https://github.com/shortcut/coding-assignment-mobile?tab=readme-ov-file).

### The challange

A client of ours has just discovered xkcd comics.
Disregarding the abundance of similar apps, she wants to create a comic viewer app, right now! She came up with a list of requirements, too! The user should be able to:

* browse through the comics,
* see the comic details, including its description,
* search for comics by the comic number as well as text,
* get the comic explanation
* favorite the comics, which would be available offline too,
* send comics to others,
* get notifications when a new comic is published,
* support multiple form factors.

There are a few services available to ease some of the bullet points.
There's the [xkcd JSON API](https://xkcd.com/json.html), which can be used to access the comics.
Then there's [xkcd search](https://relevantxkcd.appspot.com/), which can help with the search.
Finally, there's [explain xkcd](http://www.explainxkcd.com/), which offers the explanation for all the comics.

### Rules

1. The code should be submitted via GitHub.
2. It should be spendt at most 16 hours working on it.

### The process

1. (1h) Set up the project and basic structure, including loading the latest comic from the xkcd API.
2. (1h) Added the ability to get a random comic and rewrote some code for better efficiency.
3. (0,5h) Added functionality to navigate to the next or previous comic.
4. (1,5h) Save favorite comics to local storage. View a list of saved comic titles in SavedView. Only the image URLs are saved, as saving image files to persistent storage hasn't been implemented yet. An attempt was made without success, but another try will be made later if there is time.
5. (0,5h)  Added the ability to search for a comic by number. Started looking at the [xkcd search](https://relevantxkcd.appspot.com) site, but all searches returned 500 (Internal Server Error). Therefore, this feature was not pursued further.
6. (2h) Added explanations to comics. Finding the API took longer than expected. The response required significant formatting and cleanup.
7. (0,5h) Added comic number, alt text (description), and date under the comic.
8. (1h) Tried text-based search again. Found another working site, [findxkcd](https://findxkcd.com). Inspected network requests while searching to understand their API usage. Successfully integrated this into the app to perform searches by comic ID and display the results.
9. (0,5h) Created a URL linking to xkcd.com with the comic number appended at the end for sharing comics.
10. (1,5h) Refactored and cleaned up the code, moving all API calls to APIService.
11. (3h) Attempted to add a notification for new comics. The plan was to use the xkcd API to get the latest comic number and compare it with the latest comic number saved in UserDefaults. If there was a new comic, a notification would be shown. Since working with background tasks and notifications was new, considerable time was spent reading documentation and tutorials. Progress was saved on a separate branch to focus on other tasks with the remaining time.
12. (2,5h) Redid much of the code to enable scrolling through multiple comics in different categories instead of having a single page with buttons. Moved the search function to a separate tab for better user experience.
13. (0,5h) Added the app icon.

### Final time:

<img width="476" alt="Skjermbilde 2024-06-02 kl  20 43 51" src="https://github.com/AugustElvevold/xkcd-comics/assets/89490288/ffe6e2e5-c8a1-4e8a-8bdc-c15d925a24b8">



### Known issues
* Showing explanation for comics is unstable. Sometimes it does not load properly, havent had time to look into it.
* Saved comics are not very user firendly. They are just placed there to demonstrate saving at the moment.
* There are a few variables I would like to move to ComicViewModel but dont have time.
