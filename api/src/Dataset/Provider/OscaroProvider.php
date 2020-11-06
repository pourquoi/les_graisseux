<?php

namespace App\Dataset\Provider;

use App\Dataset\ProviderInterface;
use App\Entity\Energy;
use App\Entity\VehicleTree;
use App\Repository\EnergyRepository;
use App\Repository\VehicleTreeRepository;
use Doctrine\ORM\EntityManagerInterface;
use GuzzleHttp\Client;
use Symfony\Contracts\Cache\CacheInterface;
use transit\JSONReader;
use transit\JSONWriter;
use transit\Map;
use transit\Transit;

class OscaroProvider implements ProviderInterface
{
    private $em;
    private $client;
    private $cache;
    private $vehicleTreeRepository;
    private $energyRepository;

    public function __construct(EntityManagerInterface $em,
                                VehicleTreeRepository $vehicleTreeRepository,
                                EnergyRepository $energyRepository,
                                CacheInterface $datasetCache)
    {
        $this->em = $em;
        $this->vehicleTreeRepository = $vehicleTreeRepository;
        $this->energyRepository = $energyRepository;
        $this->cache = $datasetCache;
        $this->client = new Client(['base_uri' => 'https://www.oscaro.com']);
    }

    public function loadBrands($rebuild_cache=false)
    {
        $k = 'oscaro-brands';
        if( $rebuild_cache )
            $this->cache->delete($k);

        $content = $this->cache->get($k, function($item) {
            $response = $this->client->request('GET', '/xhr/nav/vehicles/fr/fr?vehicles-id=0&tree-level=root');
            if( $response->getStatusCode() == 200 ) {
                return $response->getBody()->getContents();
            } else {
                print($response->getStatusCode() . ": " . $response->getBody()->getContents());
                return false;
            }
        });

        if( $content === false ) {
            $this->cache->delete($k);
            return;
        }

        $transit = new Transit(new JSONReader(), new JSONWriter());
        /** @var Map $data */
        $data = $transit->read($content);

        $brands = $data->toAssocArray()['vehicles'][0]->toAssocArray()['children'];

        foreach($brands as $brand) {
            $b = $brand->toAssocArray();
            $id = $b['id'];
            $b = $b['labels']->toAssocArray();
            $name = strtoupper($b['label']->toAssocArray()['fr']);

            print("$id $name " . PHP_EOL);

            $vehicleBrand = $this->vehicleTreeRepository->findOneBy(['name'=>$name, 'level'=>VehicleTree::LEVEL_BRAND]);

            if( !$vehicleBrand ) {
                $vehicleBrand = new VehicleTree();
            }
            $vehicleBrand->setLevel(VehicleTree::LEVEL_BRAND);
            $vehicleBrand->setName($name);
            $this->em->persist($vehicleBrand);

            $this->loadFamilies($vehicleBrand, $id);

            $this->em->flush();
            sleep(1);
            $this->em->clear();
        }

        $this->em->flush();
    }

    public function loadFamilies($brand, $bid, $rebuild_cache=false)
    {
        $k = 'oscaro-families-' . $bid;
        if( $rebuild_cache )
            $this->cache->delete($k);

        $content = $this->cache->get($k, function($item) use ($bid) {
            $response = $this->client->request('GET', '/xhr/nav/vehicles/fr/fr?vehicles-id=' . $bid . '&tree-level=brand');
            if( $response->getStatusCode() == 200 ) {
                return $response->getBody()->getContents();
            } else {
                print($response->getStatusCode() . ": " . $response->getBody()->getContents());
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

        foreach($items as $item) {
            $fid = $item[0];
            $name = $item[1];

            print("  $fid $name" . PHP_EOL);

            $vehicleFamily = $this->vehicleTreeRepository->findOneBy(['name'=>$name, 'parent'=>$brand, 'level'=>VehicleTree::LEVEL_FAMILY]);

            if( !$vehicleFamily ) {
                $vehicleFamily = new VehicleTree();
            }
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
                print($response->getStatusCode() . ": " . $response->getBody()->getContents());
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

        foreach($items as $item) {
            $mid = $item[0];
            $name = $item[1];

            print("    $mid $name" . PHP_EOL);

            $vehicleModel = $this->vehicleTreeRepository->findOneBy(['name'=>$name, 'parent'=>$family, 'level'=>VehicleTree::LEVEL_MODEL]);

            if( !$vehicleModel ) {
                $vehicleModel = new VehicleTree();
            }
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
                print($response->getStatusCode() . ": " . $response->getBody()->getContents());
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

        foreach($items as $item) {
            $id = $item[0];
            $name = $item[1];
            $releasedate = $item[2];

            $energy = $this->energyRepository->findOneByName($item[3], 'fr');
            if( !$energy ) {
                $energy = new Energy();
                $energy->setName($item[3]);
            }

            print("      $id $name" . PHP_EOL);

            $vehicle = $this->vehicleTreeRepository->findOneBy(['parent' => $model, 'level' => VehicleTree::LEVEL_TYPE, 'energy' => $energy, 'name' => $name]);

            if (!$vehicle) {
                $vehicle = new VehicleTree();
            }

            $vehicle->setLevel(VehicleTree::LEVEL_TYPE);
            $vehicle->setReleaseDate($releasedate);
            $vehicle->setParent($model);
            $vehicle->setEnergy($energy);
            $vehicle->setName($name);
            $this->em->persist($vehicle);
        }

    }
}