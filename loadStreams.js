document.addEventListener('DOMContentLoaded', function() {
  const videoGrid = document.getElementById('videoGrid');

  // Fetch stream URLs from the JSON config file asynchronously
  fetch('./config.json')
    .then(response => response.json())
    .then(data => {
      const streams = data.streams;

      // Function to add a stream to the grid
      function addStreamToGrid(stream, index) {
        const streamBox = document.createElement('div');
        streamBox.className = 'stream-box';

        const title = document.createElement('div');
        title.className = 'stream-title';
        title.textContent = `Simulation #${index + 1}` + 
          (stream.description ? 
            (stream.description.length <= 17 ? ` - ${stream.description}` : ` - ${stream.description.substring(0, 15)}...`) : 
            '');
        streamBox.appendChild(title);

        const videoWrapper = document.createElement('div');
        videoWrapper.className = 'video-wrapper';

        const video = document.createElement('video');
        video.controls = true;
        video.autoplay = true;
        video.muted = true;
        video.loop = true;

        videoWrapper.appendChild(video);
        streamBox.appendChild(videoWrapper);
        videoGrid.appendChild(streamBox);

        return {streamBox, video};
      }

      // Create and load the streams
      streams.forEach((stream, index) => {
        const { video } = addStreamToGrid(stream, index);

        fetch(stream.url, { method: 'HEAD' })
          .then(response => {
            if (response.ok) {
              if (Hls.isSupported()) {
                const hls = new Hls();
                hls.attachMedia(video);
                hls.on(Hls.Events.MEDIA_ATTACHED, function () {
                  hls.loadSource(stream.url);
                });
              } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
                video.src = stream.url;
              }
            }
          })
          .catch(error => console.error(`Error fetching stream ${stream.url}:`, error));
      });
    })
    .catch(error => console.error("Failed to load config.json:", error));
});
