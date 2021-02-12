---
layout: post
title: How to display an image protected by header-based authentication
date: '2021-02-12 20:02:36 +0100'
comments: true
today:
  type: learned
categories: programming
tags: web-apis
versions:
  javascript: ECMAScript 2020
---

I recently had to work with an API that serves images protected by header-based
authentication. You have to send a [bearer token][bearer-token] in the
[`Authorization` header][authorization-header] for all requests, including
images. How do you display such an image in a web page?

```html
<img src='https://api.example.com/secret-image.png' />
```

This won't work because an `<img>` tag cannot send a custom header. You'll
probably get some flavor of [`401 Unauthorized`][http-401] error. It would be
trivial to make it work if authentication was based on an URL query parameter or
a cookie, but it's not as easy with a header.

<!-- more -->

## Fetch the image

You'll have to make the HTTP call to get the image yourself so you can send that
header. For example, you could do this using the [Fetch API][fetch-api]:

```js
function fetchWithAuthentication(url, authToken) {
  const headers = new Headers();
  headers.set('Authorization', `Bearer ${authToken}`);
  return fetch(url, { headers });
}
```

The fetch response contains binary data, for example PNG data. You need to
insert this data into the DOM somehow.

## Embed the image with a Base64 data URL

My first attempt was to [embed the image][data-url-image] using a [data
URL][data-url]. I used [this function I found on Stack
Overflow][base64-stack-overflow] to perform the binary-to-[Base64][base64]
conversion:

```js
function arrayBufferToBase64(buffer: ArrayBuffer) {
  return btoa(String.fromCharCode(...new Uint8Array(buffer)));
}
```

You can use [the `arrayBuffer` method][fetch-api-array-buffer] of the [fetch
`Response`][fetch-api-response] to get the data to pass to the Base64 conversion
function, then build a properly formatted data URL and use it as the source of
the image:

```js
async function displayProtectedImage(
  imageId, imageUrl, authToken
) {
  // Fetch the image.
  const response = await fetchWithAuthentication(
    imageUrl, authToken
  );

  // Convert the data to Base64 and build a data URL.
  const binaryData = await response.arrayBuffer();
  const base64 = arrayBufferToBase64(binaryData);
  const dataUrl = `data:image/png;base64,${base64}`;

  // Update the source of the image.
  const imageElement = getElementById(imageId);
  imageElement.src = dataUrl;
}
```

Here's how to use it:

```js
const imageId = 'some-image';
const imageUrl = 'https://api.example.com/secret-image.png';
const authToken = 'changeme';
displayProtectedImage(imageId, imageUrl, authToken);
```

Yay!

### So slow...

It works but I ran into an issue: if you try to display several images like this
at the same time and they are large enough, converting all this binary data to
Base64 will slow down your UI.

This is because JavaScript in the browser runs on a [single-threaded event
loop][event-loop]. Since your JavaScript runs in the same thread as the UI, any
sufficiently heavy calculation will temporary block everything, making your site
feel unresponsive.

Maybe a [web worker][web-workers] could be a solution to make sure this work is
done in a separate thread, but I did not have time to investigate.

## Use an object URL

In the end, I used the [URL Web API][url-api], specifically [its
`createObjectURL` function][url-api-create-object-url]. If you have a blob of
binary data, you can pass it to this function to create a `blob:` URL that
points to this data in memory:

```js
URL.createObjectURL(blob);
// blob:http://example.com/e88f2e72-94c6-4f79-a40d-fc6749ce
```

If your blob contains image data, you can use this new URL as the source of an
`<img>` tag. The advantage of this technique compared to constructing a data URL
is that you do not have to process the image data at all. This blob URL is
simply a point to the existing data in memory, stored in the [blob URL
store][blob-url-store], with no extra computation required.

You can get the data of a fetch `Response` as a blob by using [its `blob`
function][fetch-api-blob]. Let's rewrite the `displayProtectedImage` function to
take advantage of object URLs:

```js
async function displayProtectedImage(
  imageId, imageUrl, authToken
) {
  // Fetch the image.
  const response = await fetchWithAuthentication(
    imageUrl, authToken
  );

  // Create an object URL from the data.
  const blob = await response.blob();
  const objectUrl = URL.createObjectURL(blob);

  // Update the source of the image.
  const imageElement = getElementById(imageId);
  imageElement.src = objectUrl;
}
```

You can use it the same way as the previous version:

```js
const imageId = 'some-image';
const imageUrl = 'https://api.example.com/secret-image.png';
const authToken = 'changeme';
displayProtectedImage(imageId, imageUrl, authToken);
```

## Collect the garbage

The memory referenced by object URLs is released automatically when the document
is unloaded. However, if you're writing a single page application or generally
care about memory consumption and performance, you should let the browser know
when this memory can be released by calling [the `revokeObjectURL`
function][url-api-revoke-object-url]:

```js
URL.revokeObjectURL(someObjectUrl);
```

In the case of an image, it's easy to do it automatically as soon as the image
is done loading by using its `onload` callback. Once the image is displayed, the
object URL and the referenced data are no longer needed:

```js
imageElement.src = objectUrl;
imageElement.onload = () => URL.revokeObjectUrl(objectUrl);
```

Here's an updated `displayProtectedImage` function that does this:

```js
async function displayProtectedImage(
  imageId, imageUrl, authToken
) {
  // Fetch the image.
  const response = await fetchWithAuthentication(
    imageUrl, authToken
  );

  // Create an object URL from the data.
  const blob = await response.blob();
  const objectUrl = URL.createObjectURL(blob);

  // Update the source of the image.
  const imageElement = getElementById(imageId);
  imageElement.src = objectUrl;
  imageElement.onload = () => URL.revokeObjectUrl(objectUrl);
}
```

May your UI remain swift.

[authorization-header]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization
[base64]: https://en.wikipedia.org/wiki/Base64
[base64-stack-overflow]: https://stackoverflow.com/a/11562550
[bearer-token]: https://tools.ietf.org/html/rfc6750
[blob-url-store]: https://w3c.github.io/FileAPI/#BlobURLStore
[data-url]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs
[data-url-image]: https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Using_images#embedding_an_image_via_data_url
[event-loop]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/EventLoop
[fetch-api]: https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API
[fetch-api-array-buffer]: https://developer.mozilla.org/en-US/docs/Web/API/Body/arrayBuffer
[fetch-api-blob]: https://developer.mozilla.org/en-US/docs/Web/API/Body/blob
[fetch-api-response]: https://developer.mozilla.org/en-US/docs/Web/API/Response
[http-401]: https://httpstatuses.com/401
[url-api]: https://developer.mozilla.org/en-US/docs/Web/API/URL
[url-api-create-object-url]: https://developer.mozilla.org/en-US/docs/Web/API/URL/createObjectURL
[url-api-revoke-object-url]: https://developer.mozilla.org/en-US/docs/Web/API/URL/revokeObjectURL
[web-workers]: https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers
