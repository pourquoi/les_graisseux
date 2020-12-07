<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\AddressRepository;
use CrEOF\Spatial\PHP\Types\Geometry\Point;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * @ORM\Entity(repositoryClass=AddressRepository::class)
 */
class Address
{
    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     * @Groups({"read", "address:read", "write"})
     * @ApiProperty(writable=false)
     */
    private $id;

    /**
     * @ORM\Column(type="string", length=2)
     * @Groups({"read", "address:read", "write", "address:write"})
     */
    private $country;

    /**
     * @ORM\Column(type="string", length=255)
     * @Groups({"read", "address:read", "write", "address:write"})
     */
    private $locality;

    /**
     * @ORM\Column(type="string", length=5, nullable=true)
     * @Groups({"read", "address:read", "write", "address:write"})
     */
    private $postal_code;

    /**
     * @ORM\Column(type="string", length=255, nullable=true)
     * @Groups({"read", "address:read", "write", "address:write"})
     */
    private $street;

    /**
     * @var Point
     * @ORM\Column(type="point", nullable=true, nullable=true)
     */
    private $coordinates;

    /**
     * @var float|null
     * @Groups({"read", "address:read", "write", "address:write"})
     */
    private $latitude;

    /**
     * @var float|null
     * @Groups({"read", "address:read", "write", "address:write"})
     */
    private $longitude;

    public function getLatitude(): ?float
    {
        if ($this->coordinates) return $this->coordinates->getY();
        return null;
    }

    public function setLatitude(?float $latitude): self
    {
        if (null === $latitude) {
            $this->coordinates = null;
            return $this;
        }
        if (null === $this->coordinates) $this->coordinates = new Point([0,0]);
        $this->coordinates->setY($latitude);
        $this->latitude = $latitude;
        return $this;
    }

    public function getLongitude(): ?float
    {
        if ($this->coordinates) return $this->coordinates->getX();
        return null;
    }

    public function setLongitude(?float $longitude): self
    {
        if (null === $longitude) {
            $this->coordinates = null;
            return $this;
        }

        if (null === $this->coordinates) $this->coordinates = new Point([0,0]);
        $this->coordinates->setX($longitude);
        $this->longitude = $longitude;
        return $this;
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getCountry(): ?string
    {
        return $this->country;
    }

    public function setCountry(string $country): self
    {
        $this->country = $country;

        return $this;
    }

    public function getLocality(): ?string
    {
        return $this->locality;
    }

    public function setLocality(string $locality): self
    {
        $this->locality = $locality;

        return $this;
    }

    public function getPostalCode(): ?string
    {
        return $this->postal_code;
    }

    public function setPostalCode(?string $postal_code): self
    {
        $this->postal_code = $postal_code;

        return $this;
    }

    public function getStreet(): ?string
    {
        return $this->street;
    }

    public function setStreet(?string $street): self
    {
        $this->street = $street;

        return $this;
    }

    public function getCoordinates(): ?Point
    {
        return $this->coordinates;
    }

    public function setCoordinates($coordinates): self
    {
        if( is_array($coordinates) ) {
            $coordinates = new Point($coordinates);
        }
        $this->coordinates = $coordinates;
        return $this;
    }

}
