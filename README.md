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

1. (1h) I started by setting up the project and the basic structure. Including loading latest comic from the xkcd API.
2. (1h) I added get random comic, and rewrote some code to make it easier.
3. (0,5h) Added functionality to go to nex ot previous comic.
4. (1,5h) Save favorite comics to local storage. View a list of local comic titles in SavedView. Only saved image url, since I have not done save image file to persistent storage before. I tried without success, but will try again later if there is time.
5. (0,5h) Added search comic by number. I started looking at the [xkcd search](https://relevantxkcd.appspot.com) site but all searches was just returning `500 (Internal Server Error)`. So I wont be trying that now.
6. (2h) Added explanation to comics. I had to look too long for the api. There was a lot of formatting in the response to look for and clean up.
7. (0,5h) Added comic number, alt text (description), and date under the comic.
8. (1h) Tried search by text again. I found another site that was working [findxkcd](https://findxkcd.com). I looked at the network tab in Inspect element to see what requests was sendt when typing search words. I found it including their api key, and got it working in postman. Then I decoded the jsonresponse to get the comic id and made the app do a normal search by id (comic.num) and display it.
9. (0,5h) For sharing the comic I decided to just make an url to the xkcd.com with the comic number concatenated at the end.
10. (1,5h) Refactor and clean up code. Move all api calls to APIService.
11. (3h) Tried to add a notification for new comic. The plan was to use the xkcd API to get the latest comic number and compare it to the latest comic number saved in UserDefaults. If it was a new comic I would show a notification. I have not wokred with either backgorund tasks or notifications before, so I had to read a lot of documentation and tutorials. I saved progress on a separate branch so I can focus on other tasks with the remaining time.
12. (2,5h) I redid a lot of code to be able to scroll through multiple comics in different categories rather than having just one page with buttons. I also moved search to a separate tab for better user experience.* 
13. (0,5h) Add app icon

### Final time:

<img width="476" alt="Skjermbilde 2024-06-02 kl  20 43 51" src="https://github.com/AugustElvevold/xkcd-comics/assets/89490288/ffe6e2e5-c8a1-4e8a-8bdc-c15d925a24b8">



### Known issues
* Showing explanation for comics is unstable. Sometimes it does not load properly, havent had time to look into it.
* Saved comics are not very user firendly. They are just placed there to demonstrate saving at the moment.
* There are a few variables I would like to move to ComicViewModel but dont have time.
