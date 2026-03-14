import { useState } from 'react';
import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { PageButton } from './components/PageButton';
import type { ExaminePanelData } from './ExaminePanelData';
import { FlavorTextPage, ImageGalleryPage } from './ExaminePanelPages';

enum Page {
  FlavorText,
  ImageGallery,
}

export const ExaminePanel = (props) => {
  const { act, data } = useBackend<ExaminePanelData>();
  const { character_name, is_playing, has_song } = data;
  const imgGallery = Array.isArray(data.img_gallery) ? data.img_gallery : [];
  const nsfwImgGallery = Array.isArray(data.nsfw_img_gallery)
    ? data.nsfw_img_gallery
    : [];
  const [currentPage, setCurrentPage] = useState(Page.FlavorText);

  let pageContents;

  switch (currentPage) {
    case Page.FlavorText:
      pageContents = <FlavorTextPage />;
      break;
    case Page.ImageGallery:
      pageContents = <ImageGalleryPage />;
      break;
  }

  return (
    <Window
      title={character_name}
      width={1000}
      height={700}
      buttons={
        <>
          {1}
          <Button
            color="green"
            icon="music"
            tooltip="Music player"
            tooltipPosition="bottom-start"
            onClick={() => act('toggle')}
            disabled={!has_song}
            selected={!is_playing}
          />
        </>
      }
    >
      <Window.Content>
        <Stack vertical fill>
          {(imgGallery.length > 0 || nsfwImgGallery.length > 0) && (
            <Stack>
              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.FlavorText}
                  setPage={setCurrentPage}
                >
                  Flavor Text
                </PageButton>
              </Stack.Item>
              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.ImageGallery}
                  setPage={setCurrentPage}
                >
                  Image Gallery
                </PageButton>
              </Stack.Item>
            </Stack>
          )}
          {imgGallery.length > 0 && <Stack.Divider />}
          <Stack.Item
            grow
            position="relative"
            overflowX="hidden"
            overflowY="auto"
          >
            {pageContents}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
