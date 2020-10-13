<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Annotation\ApiSubresource;
use App\Repository\CustomerVehicleRepository;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ApiResource()
 * @ORM\Entity(repositoryClass=CustomerVehicleRepository::class)
 */
class CustomerVehicle
{
    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     */
    protected $id;

    /**
     * @var Customer
     * @ORM\ManyToOne(targetEntity="Customer", inversedBy="vehicles")
     * @ORM\JoinColumn(nullable=false)
     */
    protected $customer;

    /**
     * @var VehicleTree
     * @ORM\ManyToOne(targetEntity="VehicleTree")
     * @ORM\JoinColumn(nullable=false)
     */
    protected $type;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getCustomer(): Customer
    {
        return $this->customer;
    }

    public function setCustomer(Customer $customer): self
    {
        $this->customer = $customer;
        return $this;
    }

    public function getType(): VehicleTree
    {
        return $this->type;
    }

    public function setType(VehicleTree $type): self
    {
        $this->type = $type;
        return $this;
    }
}
