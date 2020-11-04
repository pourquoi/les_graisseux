<?php

namespace App\Tests\Endpoints;

use Symfony\Component\HttpFoundation\File\UploadedFile;
use Symfony\Component\Mime\Part\DataPart;
use Symfony\Component\Mime\Part\Multipart\FormDataPart;

class MediaObjectTest extends Base
{
    const UPLOAD_DIR = __DIR__ . '/../../public/media/test';

    public function tearDown(): void
    {
        assert(substr( self::UPLOAD_DIR, -strlen( 'public/media/test' ) ) == 'public/media/test');
        array_map('unlink', glob(self::UPLOAD_DIR . "/*.*"));
        parent::tearDown();
    }

    public function testUpload(): void
    {
        $client = self::createClient();

        $auth = self::login($client, 'alice@example.com', 'pass1234');

        $client->getKernelBrowser()->request('POST', 'http://example.com/api/media_objects', [
        ], [
            'file' => new UploadedFile(__DIR__ . '/../data/profile.jpg', 'profile.jpg')
        ], [
            'HTTP_ACCEPT' => 'application/json,application/ld+json',
            'CONTENT_TYPE' => 'application/form-data',
            'HTTP_AUTHORIZATION' => 'Bearer ' . $auth['token']
        ]);

        $response = $client->getKernelBrowser()->getResponse();
        $this->assertEquals(201, $response->getStatusCode());

        $data = json_decode($response->getContent(), true);
        $filename = explode('/', $data['thumb_url']);
        $filename = end($filename);

        $this->assertFileExists(self::UPLOAD_DIR . '/' . $filename);
    }
}