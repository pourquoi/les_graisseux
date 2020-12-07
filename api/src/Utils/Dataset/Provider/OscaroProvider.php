<?php

namespace App\Utils\Dataset\Provider;

use App\Entity\ProviderContext;
use App\Utils\Dataset\DatasetProviderInterface;
use App\Entity\Energy;
use App\Entity\VehicleTree;
use App\Repository\EnergyRepository;
use App\Repository\VehicleTreeRepository;
use Doctrine\ORM\EntityManagerInterface;
use GuzzleHttp\Client;
use Psr\Log\LoggerInterface;
use Symfony\Component\Console\Input\InputAwareInterface;
use Symfony\Contracts\Cache\CacheInterface;
use transit\JSONReader;
use transit\JSONWriter;
use transit\Map;
use transit\Transit;

class OscaroProvider implements DatasetProviderInterface
{
    const PROVIDER_KEY = 'oscaro';
    const PROVIDER_VERSION = '1.0.0';

    private $em;
    private $client;
    private $cache;
    private $vehicleTreeRepository;
    private $energyRepository;
    private $logger;

    public function __construct(EntityManagerInterface $em,
                                VehicleTreeRepository $vehicleTreeRepository,
                                EnergyRepository $energyRepository,
                                CacheInterface $datasetCache,
                                LoggerInterface $logger
    )
    {
        $this->em = $em;
        $this->logger = $logger;
        $this->vehicleTreeRepository = $vehicleTreeRepository;
        $this->energyRepository = $energyRepository;
        $this->cache = $datasetCache;
        $this->client = new Client(['base_uri' => 'https://www.oscaro.com']);
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
        $this->loadBrands();
    }

    public function loadBrands($rebuild_cache=false)
    {
        $k = 'oscaro-brands';
        if( $rebuild_cache )
            $this->cache->delete($k);

        $from_cache = false;

        $content = $this->cache->get($k, function($item) use ($from_cache) {
            $from_cache = true;
            $response = $this->client->request('GET', '/xhr/nav/vehicles/fr/fr?vehicles-id=0&tree-level=root');
            if( $response->getStatusCode() == 200 ) {
                return $response->getBody()->getContents();
            } else {
                $this->logger->warning($response->getStatusCode() . ": " . $response->getBody()->getContents());
                return false;
            }
        });

        if( $content === false ) {
            $this->cache->delete($k);
            return;
        }

        $transit = new Transit(new JSONReader(), new JSONWriter());
        $is_transit = true;
        /** @var Map $data */
        try {
            $data = $transit->read($content);
        } catch(\Exception $e) {
            $is_transit = false;
        }

        $items = [];

        if ($is_transit) {
            $brands = $data->toAssocArray()['vehicles'][0]->toAssocArray()['children'];

            $now = new \DateTime();

            foreach ($brands as $brand) {
                $b = $brand->toAssocArray();
                $id = $b['id'];
                $b = $b['labels']->toAssocArray();
                $name = strtoupper($b['label']->toAssocArray()['fr']);
                $items[] = [$id, $name];
            }
        } else {
            $brands = json_decode($content, true);

            foreach($brands['vehicles'][0]['children'] as $brand) {
                $items[] = [$brand['id'], $brand['labels']['full-label-fragment']['fr']];
            }
        }

        $now = new \DateTime();

        foreach($items as $item) {
            list($id, $name) = $item;
            $this->logger->info("$id $name ");

            $vehicleBrand = $this->vehicleTreeRepository->findOneBy(['name' => $name, 'level' => VehicleTree::LEVEL_BRAND]);

            if (!$vehicleBrand) {
                $vehicleBrand = new VehicleTree();
            }

            if (!$context = $vehicleBrand->getProviderContext(self::PROVIDER_KEY)) {
                $context = (new ProviderContext())->setProviderKey(self::PROVIDER_KEY);
                $vehicleBrand->addProviderContext($context);
            }

            $context
                ->setProvidedAt($now)
                ->setProviderVersion(self::PROVIDER_VERSION)
                ->setMetas(['id' => $id]);

            $vehicleBrand->setLevel(VehicleTree::LEVEL_BRAND);
            $vehicleBrand->setName($name);
            $this->em->persist($vehicleBrand);

            $this->loadFamilies($vehicleBrand, $id);

            $this->em->flush();
            //sleep(1);
            $this->em->clear();
        }

        $this->em->flush();
    }

    public function loadFamilies(VehicleTree $brand, $bid, $rebuild_cache=false)
    {
        $k = 'oscaro-families-' . $bid;
        if( $rebuild_cache )
            $this->cache->delete($k);

        $content = $this->cache->get($k, function($item) use ($bid) {
            $response = $this->client->request('GET', '/xhr/nav/vehicles/fr/fr?vehicles-id=' . $bid . '&tree-level=brand');
            if( $response->getStatusCode() == 200 ) {
                return $response->getBody()->getContents();
            } else {
                $this->logger->info($response->getStatusCode() . ": " . $response->getBody()->getContents());
                return false;
            }
        });

        if( $content === false ) {
            $this->cache->delete($k);
            return;
        }

        $transit = new Transit(new JSONReader(), new JSONWriter());
        $is_transit = true;
        /** @var Map $data */
        try {
            $data = $transit->read($content);
        } catch(\Exception $e) {
            $is_transit = false;
        }

        $items = [];

        if( $is_transit ) {
            $families = $data->toAssocArray()['vehicles'][0]->toAssocArray()['children'];

            foreach($families as $family) {
                $f = $family->toAssocArray();
                $fid = $f['id'];
                $f = $f['labels']->toAssocArray();
                $name = strtoupper($f['full-label-fragment']->toAssocArray()['fr']);

                $items[] = [$fid, $name];
            }
        } else {
            $families = json_decode($content, true);

            foreach($families['vehicles'][0]['children'] as $family) {
                $items[] = [$family['id'], $family['labels']['full-label-fragment']['fr']];
            }
        }

        $now = new \DateTime();

        foreach($items as $item) {
            $fid = $item[0];
            $name = $item[1];

            $this->logger->info("  $fid $name");

            $vehicleFamily = $this->vehicleTreeRepository->findOneBy(['name'=>$name, 'parent'=>$brand, 'level'=>VehicleTree::LEVEL_FAMILY]);

            if( !$vehicleFamily ) {
                $vehicleFamily = new VehicleTree();
            }

            if (!$context = $vehicleFamily->getProviderContext(self::PROVIDER_KEY)) {
                $context = (new ProviderContext())->setProviderKey(self::PROVIDER_KEY);
                $vehicleFamily->addProviderContext($context);
            }

            $context
                ->setProvidedAt($now)
                ->setProviderVersion(self::PROVIDER_VERSION)
                ->setMetas(['id'=>$fid]);

            $vehicleFamily->setLevel(VehicleTree::LEVEL_FAMILY);
            $vehicleFamily->setName($name);
            $vehicleFamily->setParent($brand);
            $this->em->persist($vehicleFamily);

            $this->loadModels($vehicleFamily, $fid, $rebuild_cache);
        }
    }

    public function loadModels($family, $fid, $rebuild_cache=false)
    {
        $k = 'oscaro-models-' . $fid;
        if( $rebuild_cache )
            $this->cache->delete($k);

        $content = $this->cache->get($k, function($item) use ($fid) {
            $response = $this->client->request('GET', '/xhr/nav/vehicles/fr/fr?vehicles-id=' . $fid . '&tree-level=family');
            if( $response->getStatusCode() == 200 ) {
                return $response->getBody()->getContents();
            } else {
                $this->logger->warning($response->getStatusCode() . ": " . $response->getBody()->getContents());
                return false;
            }
        });

        if( $content === false ) {
            $this->cache->delete($k);
            return;
        }

        $transit = new Transit(new JSONReader(), new JSONWriter());
        $is_transit = true;
        /** @var Map $data */
        try {
            $data = $transit->read($content);
        } catch(\Exception $e) {
            $is_transit = false;
        }

        $items = [];

        if( $is_transit ) {
            $models = $data->toAssocArray()['vehicles'][0]->toAssocArray()['children'];

            foreach($models as $model) {
                $m = $model->toAssocArray();
                $mid = $m['id'];
                $m = $m['labels']->toAssocArray();
                $name = strtoupper($m['full-label-fragment']->toAssocArray()['fr']);

                $items[] = [$mid, $name];
            }
        } else {
            $models = json_decode($content, true);

            foreach($models['vehicles'][0]['children'] as $model) {
                $items[] = [$model['id'], $model['labels']['label']['fr']];
            }
        }

        $now = new \DateTime();

        foreach($items as $item) {
            $mid = $item[0];
            $name = $item[1];

            $this->logger->info("    $mid $name");

            $vehicleModel = $this->vehicleTreeRepository->findOneBy(['name'=>$name, 'parent'=>$family, 'level'=>VehicleTree::LEVEL_MODEL]);

            if( !$vehicleModel ) {
                $vehicleModel = new VehicleTree();
            }

            if (!$context = $vehicleModel->getProviderContext(self::PROVIDER_KEY)) {
                $context = (new ProviderContext())->setProviderKey(self::PROVIDER_KEY);
                $vehicleModel->addProviderContext($context);
            }

            $context
                ->setProvidedAt($now)
                ->setProviderVersion(self::PROVIDER_VERSION)
                ->setMetas(['id'=>$mid]);

            $vehicleModel->setLevel(VehicleTree::LEVEL_MODEL);
            $vehicleModel->setName($name);
            $vehicleModel->setParent($family);
            $this->em->persist($vehicleModel);

            $this->loadVehicles($vehicleModel, $mid, $rebuild_cache);
        }
    }

    public function loadVehicles($model, $mid, $rebuild_cache=false)
    {
        $k = 'oscaro-vehicles-' . $mid;
        if( $rebuild_cache )
            $this->cache->delete($k);

        $content = $this->cache->get($k, function($item) use ($mid) {
            $response = $this->client->request('GET', '/xhr/nav/vehicles/fr/fr?vehicles-id=' . $mid . '&tree-level=model');
            if( $response->getStatusCode() == 200 ) {
                return $response->getBody()->getContents();
            } else {
                $this->logger->warning($response->getStatusCode() . ": " . $response->getBody()->getContents());
                return false;
            }
        });

        if( $content === false ) {
            $this->cache->delete($k);
            return;
        }

        $transit = new Transit(new JSONReader(), new JSONWriter());
        $is_transit = true;
        /** @var Map $data */
        try {
            $data = $transit->read($content);
        } catch(\Exception $e) {
            $is_transit = false;
        }

        $items = [];

        if( $is_transit ) {
            $vehicles = $data->toAssocArray()['vehicles'][0]->toAssocArray()['children'];

            foreach($vehicles as $v) {
                $v = $v->toAssocArray();
                $id = $v['id'];
                $name = $v['labels']->toAssocArray();
                $name = strtoupper($name['label']->toAssocArray()['fr']);
                $releasedate = new \DateTime($v['date'][0]->toAssocArray()['start-date']);
                $energy = $v['energy']->toAssocArray()['label']->toAssocArray()['fr'];

                $items[] = [$mid, $name, $releasedate, $energy];
            }
        } else {
            $vehicles = json_decode($content, true);

            foreach ($vehicles['vehicles'][0]['children'] as $v) {
                $id = $v['id'];
                $name = $v['labels']['label']['fr'];
                $releasedate = new \DateTime($v['date'][0]['start-date']);
                $energy = $v['energy']['label']['fr'];

                $items[] = [$id, $name, $releasedate, $energy];
            }
        }

        $now = new \DateTime();

        foreach($items as $item) {
            $id = $item[0];
            $name = $item[1];
            $releasedate = $item[2];

            $energy = $this->energyRepository->findOneByName($item[3], 'fr');
            if( !$energy ) {
                $energy = new Energy();
                $energy->setCurrentLocale('fr');
                $energy->setName($item[3]);
                $this->em->persist($energy);
                $this->em->flush();
            }

            $this->logger->info("      $id $name");

            $vehicle = $this->vehicleTreeRepository->findOneBy(['parent' => $model, 'level' => VehicleTree::LEVEL_TYPE, 'energy' => $energy, 'name' => $name]);

            if (!$vehicle) {
                $vehicle = new VehicleTree();
            }

            if (!$context = $vehicle->getProviderContext(self::PROVIDER_KEY)) {
                $context = (new ProviderContext())->setProviderKey(self::PROVIDER_KEY);
                $vehicle->addProviderContext($context);
            }

            $context
                ->setProvidedAt($now)
                ->setProviderVersion(self::PROVIDER_VERSION)
                ->setMetas(['id'=>$id]);

            $vehicle->setLevel(VehicleTree::LEVEL_TYPE);
            $vehicle->setReleaseDate($releasedate);
            $vehicle->setParent($model);
            $vehicle->setEnergy($energy);
            $vehicle->setName($name);
            $this->em->persist($vehicle);
        }

    }
}