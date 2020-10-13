<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiFilter;
use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\JobRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use App\Filter\JobDistanceFilter;

/**
 * @ApiResource()
 * @ORM\Entity(repositoryClass=JobRepository::class)
 * @ApiFilter(JobDistanceFilter::class, properties={"address.geocoordinates"})
 */
class Job
{
    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     */
    protected $id;

    /**
     * @ORM\Column(type="string", length=255)
     */
    protected $title;

    /**
     * @ORM\Column(type="text")
     */
    protected $description;

    /**
     * @ORM\Column(type="boolean", nullable=true)
     */
    protected $immobilized;

    /**
     * @ORM\Column(type="integer", nullable=true)
     */
    protected $moving_range;

    /**
     * @var bool
     * @ORM\Column(type="boolean")
     */
    protected $urgent = false;

    /**
     * @var Collection|ServiceTree[]
     * @ORM\ManyToMany(targetEntity="ServiceTree")
     */
    protected $tasks;

    /**
     * @var Customer
     * @ORM\ManyToOne(targetEntity="Customer")
     */
    protected $customer;

    /**
     * @var CustomerVehicle
     * @ORM\ManyToOne(targetEntity="CustomerVehicle")
     */
    protected $vehicle;

    /**
     * @var Address
     * @ORM\ManyToOne(targetEntity="Address")
     * @ORM\JoinColumn(nullable=false)
     */
    protected $address;

    /**
     * @var JobApplication[]|ArrayCollection
     * @ORM\OneToMany(targetEntity="JobApplication", mappedBy="job")
     */
    protected $applications;

    public function __construct()
    {
        $this->tasks = new ArrayCollection();
        $this->applications = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getMovingRange(): ?int
    {
        return $this->moving_range;
    }

    public function setMovingRange(?int $moving_range): self
    {
        $this->moving_range = $moving_range;

        return $this;
    }

    public function getTitle(): ?string
    {
        return $this->title;
    }

    public function setTitle(string $title): self
    {
        $this->title = $title;

        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(string $description): self
    {
        $this->description = $description;

        return $this;
    }

    public function getImmobilized(): ?bool
    {
        return $this->immobilized;
    }

    public function setImmobilized(?bool $immobilized): self
    {
        $this->immobilized = $immobilized;

        return $this;
    }

    public function getVehicle(): CustomerVehicle
    {
        return $this->vehicle;
    }

    public function setVehicle(CustomerVehicle $vehicle): self
    {
        $this->vehicle = $vehicle;
        return $this;
    }

    public function getTasks(): Collection
    {
        return $this->tasks;
    }

    public function addTask(ServiceTree $type): self
    {
        if( !$this->tasks->contains($type) ) {
            $this->tasks->add($type);
        }

        return $this;
    }

    public function removeTask(ServiceTree $type): self
    {
        if( $this->tasks->contains($type) ) {
            $this->tasks->remove($type);
        }

        return $this;
    }

    public function getAddress(): ?Address
    {
        return $this->address;
    }

    public function setAddress(?Address $address): self
    {
        $this->address = $address;
        return $this;
    }

    public function isUrgent(): ?bool
    {
        return $this->urgent;
    }

    public function setUrgent(bool $urgent): self
    {
        $this->urgent = $urgent;
        return $this;
    }

    public function getCustomer(): ?Customer
    {
        return $this->customer;
    }

    public function setCustomer(Customer $customer): self
    {
        $this->customer = $customer;
        return $this;
    }

    public function getApplications(): Collection
    {
        return $this->applications;
    }

    public function addApplication(JobApplication $application)
    {
        if (!$this->applications->contains($application)) {
            $this->applications->add($application);
            $application->setJob($this);
        }
        return $this;
    }

    public function removeApplication(JobApplication $application)
    {
        if ($this->applications->contains($application)) {
            $this->applications->remove($application);
        }
        return $this;
    }

}
