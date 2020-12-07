<?php

namespace App\Utils\Dataset\Provider;

use App\Entity\ProviderContext;
use App\Entity\VehicleTree;
use App\Utils\Dataset\DatasetProviderInterface;
use Doctrine\ORM\EntityManagerInterface;
use League\Flysystem\Filesystem;
use Liip\ImagineBundle\Binary\Loader\LoaderInterface;
use Liip\ImagineBundle\Imagine\Cache\Resolver\ResolverInterface;
use Liip\ImagineBundle\Service\FilterService;
use Psr\Log\LoggerInterface;
use Symfony\Component\DomCrawler\Crawler;
use Symfony\Component\HttpFoundation\File\File;
use Symfony\Component\HttpFoundation\File\UploadedFile;

class CarLogosProvider implements DatasetProviderInterface
{
    const PROVIDER_KEY = 'carlogos';
    const PROVIDER_VERSION = '1.0.0';

    private $em;
    private $logger;
    private $filterService;
    private $fs;

    public function __construct(
        EntityManagerInterface $em,
        Filesystem $fs,
        FilterService $filterService,
        LoggerInterface $logger
    )
    {
        $this->em = $em;
        $this->logger = $logger;
        $this->fs = $fs;
        $this->filterService = $filterService;
    }

    public function getKey(): string
    {
        return self::PROVIDER_KEY;
    }

    public function getVersion(): string
    {
        return self::PROVIDER_VERSION;
    }

    public function update(): void
    {
        $local_only = true;
        $force_rebuild = false;

        $brands = $this->em->createQueryBuilder()
            ->select('b')
            ->from(VehicleTree::class, 'b')
            ->where('b.level = :brand')
                ->setParameter('brand', VehicleTree::LEVEL_BRAND)
            ->andWhere('b.logoPath IS NULL')
            ->getQuery()
            ->iterate()
            ;

        /** @var VehicleTree $brand */
        foreach($brands as $row) {
            $brand = $row[0];

            $names = [];
            $names[] = $brand->getName();
            $name = ucwords(strtolower($brand->getName()), ' -');
            $name = str_replace(' ', '-', $name);
            $names[] = $name;
            $name = strtolower($brand->getName());
            $name = str_replace(' ', '-', $name);
            $names[] = $name;

            if (!$force_rebuild) {
                foreach ($names as $name) {
                    foreach (['png', 'jpg', 'jpeg'] as $ext) {
                        $path = $name . '.' . $ext;
                        if ($this->fs->has($path)) {
                            $this->logger->info('Found local logo ' . $path);
                            $brand->setLogoPath($path);
                            $this->em->flush();
                            break;
                        }
                    }

                    if ($brand->getLogoPath()) {
                        continue 2;
                    }
                }
            }

            if ($local_only) {
                continue;
            }

            $html = false;
            foreach($names as $name) {
                foreach(['png', 'jpg', 'jpeg'] as $ext) {
                    $path = $name . '.' . $ext;
                    if ($this->fs->has($path)) {
                        $brand->setLogoPath($path);
                        break;
                    }
                }

                $url = 'https://www.carlogos.org/car-brands/' . $name . '-logo.html';

                $this->logger->info('Logo search at ' . $url);

                $html = @file_get_contents($url);
                sleep(1);

                if (false === $html) {
                    continue;
                } else {
                    break;
                }
            }

            if (!$html) continue;

            $crawler = new Crawler($html);
            $urls = $crawler = $crawler->filter('a')->extract(['href']);

            $logo_url = null;
            $symbol_url = null;

            foreach($urls as $url) {
                if (!$symbol_url && strpos($url, '-symbol-') !== false) {
                    $symbol_url = $url;
                }
                if (!$logo_url && strpos($url, '-logo-') !== false) {
                    $logo_url = $url;
                }
                if ($logo_url && $symbol_url) {
                    break;
                }
            }

            if ($logo_url || $symbol_url) {
                $url = $symbol_url ?? $logo_url;
                $this->logger->info('Found logo ' . $url);
                $content = @file_get_contents($url);
                if (!$content) {
                    continue;
                }

                $path = $name . '.' . pathinfo($url)['extension'];
                if ($this->fs->put($path, $content)) {
                    $brand->setLogoPath($path);

                    if (!$context = $brand->getProviderContext(self::PROVIDER_KEY)) {
                        $context = (new ProviderContext())->setProviderKey(self::PROVIDER_KEY);
                        $brand->addProviderContext($context);
                    }

                    $context
                        ->setProvidedAt(new \DateTime())
                        ->setProviderVersion(self::PROVIDER_VERSION)
                        ->setMetas(['url' => $url]);

                    $this->em->flush();

                    //$this->filterService->getUrlOfFilteredImage($path, 'thumb', 'brand');
                }
            }
        }
    }
}