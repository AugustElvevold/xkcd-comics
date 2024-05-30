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
