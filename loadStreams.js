document.addEventListener('DOMContentLoaded', function() {
  const videoGrid = document.getElementById('videoGrid');

  // Number of columns for the desired fixed grid layout
  const cols = 4; 

  // Calculate the grid width
  const streamBoxWidth = 260; // Width in pixels for each stream box
  const gridGap = 10; 
  const totalGridWidth = cols * streamBoxWidth + (cols - 1) * gridGap;

  // Adjust the .video-grid container to control its width and centering
  videoGrid.style.maxWidth = `${totalGridWidth}px`;
  videoGrid.style.margin = 'auto';
  videoGrid.style.display = 'grid';
  videoGrid.style.gridTemplateColumns = `repeat(${cols}, 1fr)`;
  videoGrid.style.gridGap = `${gridGap}px`;

  // Define an array with all the stream URLs (add 'http://...' if needed)
  const streamUrls = [
    'output_1.m3u8',
    'output_2.m3u8',
    'output_3.m3u8',
    'output_4.m3u8',
    'output_5.m3u8',
    'output_6.m3u8',
    'output_7.m3u8',
    'output_1.m3u8',
    'output_2.m3u8',
    'output_3.m3u8',
    'output_4.m3u8',
    'output_5.m3u8',
    'output_6.m3u8',
    'output_7.m3u8',
    'output_7.m3u8',
    'output_8.m3u8'
  ];

  // Function to add a stream to the grid
  function addStreamToGrid(streamUrl, index) {
    const streamBox = document.createElement('div');
    streamBox.className = 'stream-box';

    const title = document.createElement('div');
    title.className = 'stream-title';
    title.textContent = `Simulation #${index + 1}`;
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
  streamUrls.forEach((streamUrl, index) => {
    const { video } = addStreamToGrid(streamUrl, index);

    fetch(streamUrl, { method: 'HEAD' })
      .then(response => {
        if (response.ok) {
          if (Hls.isSupported()) {
            const hls = new Hls();
            hls.attachMedia(video);
            hls.on(Hls.Events.MEDIA_ATTACHED, function () {
              hls.loadSource(streamUrl);
            });
          } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
            video.src = streamUrl;
          }
        }
      })
      .catch(error => console.error(`Error fetching stream ${streamUrl}:`, error));
  });
});
